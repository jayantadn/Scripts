# Configuration
ZIP = "T:\\ProgramFiles\\7-ZipPortable\\App\\7-Zip64\\7zG.exe"

# All imports
import os
import sys
import subprocess

# function definitions
def myassert(expr, msg) :
    if not expr :
        print("ERROR: " + msg)
        input("Press enter to exit...")
        exit(1)
        
# program entry point
if __name__ == "__main__" :
    # doing some sanity checks
    myassert( os.path.exists(ZIP), "7z path invalid" )
        
    # compute the output file name
    if len(sys.argv) == 2 :
        outfile = sys.argv[1] + ".zip"
    elif len(sys.argv) > 2 :
        dirname = os.path.dirname( sys.argv[1] )
        if not dirname :
            dirname = os.getcwd()
        outfile = os.path.join( dirname, os.path.basename(dirname) + ".zip" )
    else :
        myassert(False, "Invalid number of parameters")

    # Execute 7z command to compress given files
    sys.argv.pop(0) # remove the 7z exe name
    command = [ ZIP, "a", "-tzip", "-mx9",  outfile ]
    for path in sys.argv :
        myassert( os.path.exists(path), "Path does not exist: " + path )                
        command.append( path )
    try :
        myassert(subprocess.call( command ) == 0, "Failed to execute 7z command")
    except :
        myassert(False, "Failed to execute 7z command")
    
