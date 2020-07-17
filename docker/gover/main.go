package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"math"
	"net"
	"net/http"
	"os"
	"runtime"
	"time"

	log "github.com/sirupsen/logrus"
)

// GitCommit - To be subsituted at compile time
var GitCommit string

// Httpport - String for ListenAndServer
const Httpport string = ":3000"

func webhome(w http.ResponseWriter, r *http.Request) {
	log.Info("HTTP Handler called for home")
	w.Header().Set("Server", "A Go Web Server")
	w.WriteHeader(200)
	w.Write([]byte("Hello from Web Server"))
}

// GlobalVersionType - needs to be all capital for JSON marshalling
type GlobalVersionType struct {
	Version       int
	LastCommitSHA string
	Description   string
	// Sources to be monitored - typically directories
}

// GlobalConfigurationType - The Global Configuration
type GlobalConfigurationType struct {
	// List of Sources to be monitored - typically directories (also known as Inboxes)
	Sources []string
	// List of File Extensions that single the file is ready to be moved for each Source
	SourceExtensions []string
	// List of Destinations for File Transfers (also known as Outboxes)
	Destinations []string
	// Restrict the IP addresses that can connect to the Web Server
	RestrictWebServer string
	// Enable Network Listener to wait for File Transfers
	EnableNETFileListener bool
	// Enable Network Listener to wait for File Transfers
	EnableHTTPFILEListener bool
}

// GlobalConfigurationType - The Global Configuration
type GlobalTelemtry struct {
	// Total Number of Files processed - since starting
	TotalFilesProcessed int64
	// Total Number of Files processed - last hour
	TotalFilesLastHour int64
	// Total Bytes processed - since starting
	TotalBytesProcessed int64
	// Total Bytes processed - last hour
	TotalBytesLastHour int64
	// Total Number of Files processed - last hour
}

// ByteCountS Counts Bytes into human readable form (SI units - KB)
func ByteCountSI(b int64) string {
	const unit = 1000
	if b < unit {
		return fmt.Sprintf("%6dB", b)
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
			i = i + 9185960
		} else {
			i = i + 2
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
	//s := buf.String()
	return string(content)
}

//func keepLines(s string, n int) string {
//	result := strings.Join(strings.Split(s, "\n")[:n], "\n")
//	return strings.Replace(result, "\r", "", -1)
//}

//func GetExternalIP() string {
//	resp, err := http.Get("http://ipv4.myexternalip.com/raw")
//	if err != nil {
//		return ("")
//	}
//	defer resp.Body.Close()
//
//}

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

func startwebserver() {
	// Web Server
	http.HandleFunc("/", webhome)
	http.HandleFunc("/version", webversion)

	log.Info("Starting WebServer @", Httpport)
	log.Fatal(http.ListenAndServe(Httpport, nil))
}

func initialize() {
	// Info - move to a dedicated spot later
	path, err1 := os.Executable()
	if err1 != nil {
		log.Println(err1)
		log.Fatal("Cannot determine executable name!")
	}

	GlobalConfiguration := GlobalConfigurationType{
		Sources:                []string{"/app1/inbox1", "/app1/inbox2"},
		SourceExtensions:       []string{".OK", ".ok"},
		Destinations:           []string{"/app1/outbox1", "/app1/outbox2"},
		RestrictWebServer:      "string",
		EnableNETFileListener:  true,
		EnableHTTPFILEListener: false,
	}
	log.Info(GlobalConfiguration.Sources[0])
	log.Info(GlobalConfiguration.Sources[1])
	log.Info(GlobalConfiguration.SourceExtensions[0])
	log.Info(GlobalConfiguration.SourceExtensions[1])
	log.Info(GlobalConfiguration.Destinations[0])
	log.Info(GlobalConfiguration.Destinations[1])

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

	log.Info("Start Time: ", time.Now())
	log.Info("Program   : ", path)

	args := os.Args[1:]
	log.Info("Parameters: ", args)

	log.Info("====PLATFORM INFO====")
	log.Info("GOOS   = ", runtime.GOOS)
	log.Info("GOARCH = ", runtime.GOARCH)
	log.Info("GOVER  = ", runtime.Version())
	log.Info("CPU Threads = ", runtime.NumCPU())
	log.Info("====PLATFORM INFO====")

	log.Info("====RUNTIME INFO====")
	log.Info("Process ID  = ", os.Getpid())
	log.Info("User ID     = ", os.Getuid())
	log.Info("Group ID    = ", os.Getgid())
	log.Info("====RUNTIME INFO====")
	log.Info("====NETWORK INFO====")
	log.Info("Hostname              = ", hostname)
	log.Info("IP Address (Local)    = ", GetLocalIP())
	// log.Info("Router Address        = ", GetLocalGateway())
	log.Info("IP Address (External) = ", GetExternalIP())
	log.Info("====NETWORK INFO====")

	// GIT Info
	log.Info("====GIT INFO===")
	log.Info("GitCommit =", GitCommit)
	log.Info("====GIT INFO===")

	//testbytecount1()
	//testbytecount2()
	testbytecount3()
}

func main() {
	initialize()
	startwebserver()
	log.Info("===EXITING==")
}
