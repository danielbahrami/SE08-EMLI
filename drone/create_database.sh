#!/bin/bash

# Path to the SQLite database
databasePath="/home/simonplatz/database/wifi_log.db"

# Create the SQLite database and table
sqlite3 $databasePath "CREATE TABLE IF NOT EXISTS WifiLog (epoch INTEGER, link_quality REAL, signal_level REAL);"
