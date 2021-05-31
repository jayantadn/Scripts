# Configuration
ZIP = "T:\\ProgramFiles\\7-ZipPortable\\App\\7-Zip64\\7z.exe"

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

# checks if the zip file has multiple files/folders at root level
def hasMultiFiles(zipfile) :
    try :
        out = subprocess.check_output( [ ZIP, "l", zipfile ] ).decode("utf-8")
    except :
        myassert( False, "Could not list contents of archive" )
        
    lines = out.splitlines()
    linenum = lines.index("------------------- ----- ------------ ------------  ------------------------") + 2 # safe to skip the first file, as its always going to be a root level file/folder
    lines.reverse()
    endlinenum = len(lines) - lines.index("------------------- ----- ------------ ------------  ------------------------") - 1
    lines.reverse()
    while linenum < endlinenum :
        if "\\" not in lines[linenum] :
            return True
        linenum += 1
    return False
        
# program entry point
if __name__ == "__main__" :
    # doing some sanity checks
    myassert( os.path.exists(ZIP), "7z path invalid" )
    myassert(len(sys.argv) == 2, "Invalid number of parameters")
    myassert( os.path.exists(sys.argv[1]), "Zip file does not exist" )
    
    # if the zip file has multiple files at root level, then unzip into a new folder
    outdir = os.path.dirname(sys.argv[1])
    if hasMultiFiles(sys.argv[1]) :
        outdir = os.path.join( outdir, os.path.basename(sys.argv[1]).split(".")[0] )
    try :
        ret = subprocess.call( [ ZIP, "x", sys.argv[1], "-o" + outdir, "-y" ] )
        myassert( ret == 0, "Could not extract archive" )
    except :
        myassert( False, "Could not extract archive" )
        