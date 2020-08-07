package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"math"
	"net"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"os/user"
	"runtime"
	"syscall"
	"time"

	log "github.com/sirupsen/logrus"
)

// To be subsituted at compile time
var (
	Repo      string
	Hash      string
	Version   string
	BuildDate string
)

//GlobalVersionType - needs to be all capital for JSON marshalling
type GlobalVersionType struct {
	Version       int
	LastCommitSHA string
	Description   string
}

//GlobalConfigurationBasicType - The Global Configuration
type GlobalConfigurationBasicType struct {
	// Httpport - String for ListenAndServer
	Httpport  string
	StartTime time.Time
}

//GlobalConfiguraitonBasic - The Global Configuration
var GlobalConfiguraitonBasic GlobalConfigurationBasicType

// GlobalConfigurationAppType - The Global Configuration
type GlobalConfigurationAppType struct {
	// List of Sources to be monitored - typically directories (also known as Inboxes)
	Sources string
	// Extension of trigger files
	TriggerExts string
	// Extension of process/instruction files
	ProcessExts string
	// List of Destinations (URLs) to be sent to
	DestinationURLs string
	// Restrict the IP addresses that can connect to the Web Server
}

//webhome responder
func webhome(w http.ResponseWriter, r *http.Request) {
	log.Info("HTTP Handler called for home")
	w.Header().Set("Server", "A Go Web Server")
	w.WriteHeader(200)
	w.Write([]byte("Hello from Web Server"))
}

// ByteCountSI Counts Bytes into human readable form (SI units - KB)
func ByteCountSI(b int64) string {
	const unit = 1000
	if b < unit {
		return fmt.Sprintf("%dBytes", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%5.1f%cB",
		float64(b)/float64(div), "kMGTPE"[exp])
}

// ByteCountIEC Counts Bytes into human readable form (IEC units - KiB)
func ByteCountIEC(b int64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%8dB", b)
	}
	div, exp := int64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%6.1f%ciB",
		float64(b)/float64(div), "KMGTPE"[exp])
}

func testbytecount1() {
	fmt.Printf("%20s %16s %16s\n", "Input", "BytecountSI", "BytecountIEC")
	for _, b := range []int64{
		999, 1000, 1023, 1024, 1029999, 409604096,
		6987654321, math.MaxInt64,
	} {
		fmt.Printf("%20d %16q %16q\n",
			b,
			ByteCountSI(b),
			ByteCountIEC(b))
	}
}

func testbytecount2() {
	fmt.Printf("%20s %16s %16s\n", "Input", "BytecountSI", "BytecountIEC")
	for _, b := range []int64{
		999, 1000, 1023, 1024, 1029999, 409604096,
		6987654321, math.MaxInt64,
	} {
		fmt.Printf("%20d %16q %16q\n",
			b,
			ByteCountSI(b),
			ByteCountIEC(b))
	}
}

func testbytecount3() {
	var i int64
	for i = 1; i < 2112971802400; i++ {
		if i > 1096000 {
			i += 9185960
		} else {
			i += 2
		}

		fmt.Printf("\r(%8s)",
			ByteCountSI(i),
		)
	}
	fmt.Printf("\n")
}

// GetLocalIP returns the non loopback local IP of the host
func GetLocalIP() string {
	addrs, err := net.InterfaceAddrs()
	if err != nil {
		return ""
	}
	for _, address := range addrs {
		// check the address type and if it is not a loopback the display it
		if ipnet, ok := address.(*net.IPNet); ok && !ipnet.IP.IsLoopback() {
			if ipnet.IP.To4() != nil {
				return ipnet.IP.String()
			}
		}
	}
	return ""
}

// GetExternalIP Determine external IP Address
func GetExternalIP() string {
	var http = &http.Client{
		Timeout: time.Second * 2,
	}
	resp, err := http.Get("http://myexternalip.com/raw")
	if err != nil {
		return ""
	}
	defer resp.Body.Close()
	content, _ := ioutil.ReadAll(resp.Body)
	buf := new(bytes.Buffer)
	buf.ReadFrom(resp.Body)
	return string(content)
}

func webversion(w http.ResponseWriter, r *http.Request) {
	log.Info("HTTP Handler called for version")
	log.Debug("HTTP Handler called for version", r)

	GlobalVersion := GlobalVersionType{
		Version:       23,
		LastCommitSHA: "123456",
		Description:   "pre-interview technical test",
	}
	b, err := json.Marshal(GlobalVersion)
	if err != nil {
		log.Fatal("Json Mashalling failed with", err)
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(b)
}

func startwebserver(Httpport string) {
	// Web Server
	http.HandleFunc("/", webhome)
	http.HandleFunc("/version", webversion)

	log.Info("Starting WebServer @", Httpport)
	log.Fatal(http.ListenAndServe(Httpport, nil))
}

// GlobalConfigurationApp xxx
var GlobalConfigurationApp []GlobalConfigurationAppType

func prgstatus() {
	info := syscall.Sysinfo_t{}
	err := syscall.Sysinfo(&info)

	if err != nil {
		log.Fatalf("Unable to retreive system status, had error: %s", err)
	}

	t := time.Now()
	elapsed := t.Sub(GlobalConfiguraitonBasic.StartTime)
	elapsedint := int64(elapsed) / int64(time.Minute)

	// uptime seconds since boot
	log.Warnf("Status: Uptime: % 5dmins, Total Files Processed: % 6d Failed: % 6d, Ok: % 6d, Total Size: %s",
		elapsedint,
		GlobalTelemetry.TotalFilesProcessed,
		GlobalTelemetry.TotalFilesFailure,
		GlobalTelemetry.TotalFilesSuccess,
		ByteCountSI(GlobalTelemetry.TotalFilesBytes),
	)
}

// SetupHandler creates a 'listener' on a new goroutine which will notify the
// program if it receives an interrupt from the OS. We then handle this by calling
// our clean up procedure and exiting
// not this does not fire on runtime errors
func SetupHandler() {
	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-c
		fmt.Println("")
		log.Error("Ctrl+C pressed or killed....")
		log.Fatal("Exiting")
	}()
}

// Call before main
func init() {

	// handle control-c, kill etc..
	SetupHandler()

	// Get Starttime - useful later
	GlobalConfiguraitonBasic.StartTime = time.Now()

	// Needs to move to a database or config file / something else
	GlobalConfiguraitonBasic.Httpport = ":3000"
	GlobalConfigurationApp = []GlobalConfigurationAppType{
		GlobalConfigurationAppType{
			Sources:         "/app1/inbox1",
			TriggerExts:     ".ok",
			ProcessExts:     ".txt",
			DestinationURLs: "/app1/outbox1",
		},
		GlobalConfigurationAppType{
			Sources:         "/app1/inbox2",
			TriggerExts:     ".ok",
			ProcessExts:     ".txt",
			DestinationURLs: "/app1/outbox2",
		},
	}

	// Info - move to a dedicated spot later
	path, err1 := os.Executable()
	if err1 != nil {
		log.Println(err1)
		log.Fatal("Cannot determine executable name!")
	}

	// Info - move to a dedicated spot later
	hostname, err2 := os.Hostname()
	if err2 != nil {
		log.Println(err2)
		log.Fatal("Cannot determine hostname!")
	}

	// SetFormat
	log.SetFormatter(&log.TextFormatter{
		DisableColors: false,
		FullTimestamp: false,
	})
	// JSON Logs - works beter with Splunk etc...
	// log.SetFormatter(&log.JSONFormatter{})

	// Warning true adds overhead
	log.SetReportCaller(false)

	// Only log the warning severity or above.
	log.SetLevel(log.InfoLevel)

	user, err := user.Current()
	if err != nil {
		log.Fatal("Cannot determine username!")
	}

	StartTime := time.Now()
	log.Info("Start Time      : ", StartTime)

	log.Info("Program         : ", path)
	log.Info("Running as      : ", user.Username+" ("+user.Uid+")")

	if user.Username == "root" {
		log.Warning("Running as root user! - this is probably not a good idea")
	}

	cwd, err := os.Getwd()
	if err != nil {
		log.Fatal("Cannot determine Current Working Directory")
	}

	log.Info("Running from    : ", cwd)

	args := os.Args[1:]
	log.Info("Parameters      : ", args)

	log.Info("====GOLANG INFO====")
	log.Info("GOOS            = ", runtime.GOOS)
	log.Info("GOARCH          = ", runtime.GOARCH)
	log.Info("GOVER           = ", runtime.Version())
	log.Info("Maximum Threads = ", runtime.NumCPU())
	log.Info("====PLATFORM INFO====")

	log.Info("====ORACLE INFO====")
	log.Info("ORACLE_HOME     = ", os.Getenv("ORACLE_HOME"))
	log.Info("ORACLE_SID      = ", os.Getenv("ORACLE_SID"))
	log.Info("LD_LIBRARY_PATH = ", os.Getenv("LD_LIBRARY_PATH"))
	log.Info("====ORACLE INFO====")

	log.Info("====RUNTIME INFO=====")
	log.Info("Process ID      = ", os.Getpid())
	log.Info("User ID         = ", os.Getuid())
	log.Info("Group ID        = ", os.Getgid())
	log.Info("====RUNTIME INFO=====")
	log.Info("====NETWORK INFO=====")
	log.Info("Hostname             = ", hostname)
	log.Info("IP Address (Local)   = ", GetLocalIP())
	// log.Info("Router Address        = ", GetLocalGateway())
	log.Info("IP Address (External)= ", GetExternalIP())
	log.Info("====NETWORK INFO=====")

	// GIT Info
	log.Info("====GIT INFO===")
	log.Info("Repo Name            = ", Repo)
	log.Info("Repo HASH            = ", Hash)
	log.Info("Repo Version         = ", Version)
	log.Info("Code Build Date      = ", BuildDate)

	// git clone $URL
	// cd $PROJECT_NAME
	// git reset --hard $SHA1

	log.Info("====GIT INFO===")

	//testbytecount1()
	//testbytecount2()
	//testbytecount3()
}

func main() {

	go startwebserver(GlobalConfiguraitonBasic.Httpport)
	time.Sleep(2 * time.Second)

	// GlobalConfigurationApp = []GlobalConfigurationAppType{

	// Process Files first - since the fsnotify does not pick upfiles that already exists
	Processdir(GlobalConfigurationApp[0].Sources,
		GlobalConfigurationApp[0].TriggerExts,
		GlobalConfigurationApp[0].ProcessExts)

	// As a Go Routine - run fsnotify for the specified directory
	go Watchdirectory(GlobalConfigurationApp[0].Sources,
		GlobalConfigurationApp[0].TriggerExts,
		GlobalConfigurationApp[0].ProcessExts)

	time.Sleep(4 * time.Second)
	log.Infof("======== Finished Starting Up...waiting for something to happen! ========")

	prgstatus()
	for ok := true; ok; ok = true {
		time.Sleep(1 * time.Minute)
		prgstatus()
	}

	// should never get here
	log.Fatal("===EXITING==")
}

func testurl() {
	url, err := url.Parse("http://bing.com/search?q=dotnet")
	if err != nil {
		log.Fatal("URL parse failed", err)
	}
	url.Scheme = "sftp"
	url.Host = "google.com"
	q := url.Query()
	log.Info("---", url.Hostname())
	log.Info("---", q)
	q.Set("q", "golang")
	url.RawQuery = q.Encode()
	log.Info(url)
	aaaa, _ := url.Parse("https://cnn.com")
	log.Info(aaaa)
}
