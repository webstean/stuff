package main

import (
	"os"
	"path"
	"path/filepath"
	"strings"
	"time"

	"github.com/fsnotify/fsnotify"
	log "github.com/sirupsen/logrus"
)

var (
	// Dice demo
	Dice = "🎲"
	// Dart demo
	Dart = "🎯"
	//Ball demo
	Ball = "🏀"
)

// GlobalTelemetryType - Type for telemetry data
type GlobalTelemetryType struct {
	// Total Number of Files processed - since starting
	TotalFilesProcessed int64
	// Total Number of Files processed sucessfully
	TotalFilesSuccess int64
	// Total Number of Files processed sucessfully
	TotalFilesFailure int64
}

// GlobalTelemetry - telemetry data
var GlobalTelemetry GlobalTelemetryType

// ProcessFile aaaa
func ProcessFile(fsnotifyfilename string, triggerext string, processext string) bool {

	// Check that the fsnotifyfilename file exists
	// Traps any buys or double notifications
	_, err1 := os.Stat(fsnotifyfilename)
	if os.IsNotExist(err1) {
		log.Errorf("Event   : Triggered - but the specified file %s was not found", fsnotifyfilename)
		return false
	}

	// Check that fsnotifyfilename is not a directory
	fi, _ := os.Stat(fsnotifyfilename)
	mode := fi.Mode()
	if mode.IsDir() {
		log.Infof("Skipping    : %s as it is a directory", fsnotifyfilename)
		return false
	}

	// Strip out Extension from fsnotifyfilename
	extension := path.Ext(fsnotifyfilename)
	fsnotifyfilenamenoext := strings.TrimSuffix(fsnotifyfilename, extension)

	// Create trigger and processing filenames
	triggerfile := fsnotifyfilenamenoext + triggerext
	processfile := fsnotifyfilenamenoext + processext

	log.Infof("Trigger File: %s", triggerfile)
	log.Infof("Process File: %s", processfile)
	GlobalTelemetry.TotalFilesProcessed++

	// Check if trigger file exists
	_, err2 := os.Stat(triggerfile)
	if os.IsNotExist(err2) {
		log.Errorf("Not Found : trigger file %s was not found!", triggerfile)
		GlobalTelemetry.TotalFilesFailure++
		return false
	}

	// Check if process file exists
	_, err3 := os.Stat(processfile)
	if os.IsNotExist(err3) {
		log.Errorf("Process File: %s not found!", processfile)
		log.Warnf("Trigger File: %s deleted, as process file %s was not found!", triggerfile, processfile)
		os.Remove(triggerfile)
		GlobalTelemetry.TotalFilesFailure++
		return false
	}

	// Time to process file - processfilename
	GlobalTelemetry.TotalFilesSuccess++
	return true
}

// Watchdirectory dirname: directory to be watched,
// recursize (true or false ) recurisovely sively gotrigger pattern (regexp) to firer event when file found
// found.
func Watchdirectory(dirname string, triggerext string, processext string) {
	watcher, err := fsnotify.NewWatcher()

	if err != nil {
		log.Fatalf("Failed to create watcher (fsnotify) with error: %s", err)
	}

	// Make sure Water get closed after existing this function
	defer watcher.Close()

	log.Infof("%s Watching for files in directory: %s", Dice, dirname)

	done := make(chan bool)

	go func() {
		for {
			time.Sleep(3 * time.Second)
			select {
			// slow thing down - 3 second wait
			case event, ok := <-watcher.Events:
				if !ok {
					return
				}
				if event.Op&fsnotify.Write == fsnotify.Write {
					ProcessFile(event.Name, triggerext, processext)
				}
			case err, ok := <-watcher.Errors:
				if !ok {
					return
				}
				log.Error("Watcher (fsnotify) Event Error:", err)
			}
		}
	}()

	// Watch the passed folder for changes.
	if err := watcher.Add(dirname); err != nil {
		log.Fatalf("Failed to add watch directory with the following error: %s", err)
	}
	<-done
}

// Processdir we need this because fsnotify only chatches files when it is running, so
// any existing files on startup won't be processed.
func Processdir(dirname string, triggerext string, processext string) {
	log.Infof("Processing existing files in %s...prior to starting watcher", dirname)
	var files []string
	err := filepath.Walk(dirname, func(path string, info os.FileInfo, err error) error {
		files = append(files, path)
		return nil
	})
	if err != nil {
		log.Fatalf("Processing Directory failed with the error: %s", err)
	}
	for _, file := range files {
		ProcessFile(file, triggerext, processext)
	}
}
