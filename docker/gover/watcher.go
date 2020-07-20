package main

import (
	"regexp"
	"time"

	"github.com/radovskyb/watcher"
	log "github.com/sirupsen/logrus"
)

// Watchdirectory dirname: directory to be watched,
// recursize (troe or false ) recurisovely sively gotrigger pattern (regexp) to firer event when file found
// found.
func Watchdirectory(dirname string, recursive bool, triggerpattern string) {
	w := watcher.New()

	// SetMaxEvents to 1 to allow at most 1 event's to be received
	// on the Event channel per watching cycle.
	//
	// If SetMaxEvents is not set, the default is to send all events.
	//w.SetMaxEvents(1)

	// Only notify rename and move events.
	//w.FilterOps(watcher.Rename, watcher.Move)

	// Only files that match the regular expression during file listings
	// will be watched.
	r := regexp.MustCompile(triggerpattern)
	w.AddFilterHook(watcher.RegexFilterHook(r, false))

	log.Info("Watching for files in the director:", dirname)
	log.Info("Recursively: ", recursive)
	log.Info("that matches this regexp pattern: ", triggerpattern)

	go func() {
		for {
			select {
			case event := <-w.Event:
				// fmt.Println(event) // Print the event's info.
				log.Info("New File found: ", event.Path)
			case err := <-w.Error:
				log.Fatalln(err)
			case <-w.Closed:
				return
			}
		}
	}()

	// Watch passed folder for changes.
	if recursive {
		if err := w.AddRecursive(dirname); err != nil {
			log.Fatalln(err)
		}
	} else {
		if err := w.Add(dirname); err != nil {
			log.Fatalln("Failed to add watch directory", err)
		}
	}

	// Watch passed folder recursively for changes.

	// Print a list of all of the files and folders currently
	// being watched and their paths.
	for path, f := range w.WatchedFiles() {
		log.Info("Existing File found: ", path)
		log.Debug("Existing File found (Detailed): ", f)
	}

	// fmt.Println()

	// Just wait for files to be created
	go func() {
		w.Wait()
		w.TriggerEvent(watcher.Create, nil)

	}()

	// Start the watching process - it'll check for changes every 100ms.
	if err := w.Start(time.Millisecond * 100); err != nil {
		log.Fatalln(err)
	}
}
