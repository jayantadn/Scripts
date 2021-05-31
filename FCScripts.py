# Configuration
ZIP = "T:\\ProgramFiles\\7-ZipPortable\\App\\7-Zip64\\7zG.exe"
BUPDIR = "X:\\Backup"

# All imports
import os
import sys
import subprocess
import time
import shutil

# function definitions
def myassert(expr, msg) :
    if not expr :
        print("ERROR: " + msg)
        input("Press enter to exit...")
        exit(1)
        
# Compress a list of files provided
def Compress(filelist) :
    # compute the output file name
    if len(filelist) == 1 :
        outfile = filelist[0].rstrip("\\") + ".zip"
    elif len(filelist) > 1 :
        dirname = os.path.dirname( filelist[0] )
        if not dirname :
            dirname = os.getcwd()
        outfile = os.path.join( dirname, os.path.basename(dirname) + ".zip" )
    else :
        myassert(False, "Invalid number of parameters")

    # Execute 7z command to compress given files
    command = [ ZIP, "a", "-tzip", "-mx9",  outfile ]
    for file in filelist :
        myassert( os.path.exists(file), "File does not exist: " + file )
        command.append( file.rstrip("\\") )
    try :
        ret = subprocess.call( command )
        myassert(ret == 0, "Failed to execute 7z command")
        return outfile
    except :
        myassert(False, "Failed to execute 7z command")


# Uncompress a zip file
def Uncompress(zipfile) :
    outdir = os.path.dirname(zipfile)
    if hasMultiFiles(zipfile) :
        outdir = os.path.join( outdir, os.path.basename(zipfile).split(".")[0] )

    try :
        ret = subprocess.call( [ ZIP, "x", zipfile, "-o" + outdir, "-y" ] )
        myassert( ret == 0, "Could not extract archive" )
    except :
        myassert( False, "Could not extract archive" )


# checks if the zip file has multiple files/folders at root level
def hasMultiFiles(zipfile) :
    ZIPL = os.path.join( os.path.dirname(ZIP), "7z.exe" ) # for listing files of an archive, we need pure command line
    try :
        out = subprocess.check_output( [ ZIPL, "l", zipfile ] ).decode("utf-8")
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
    # doing some common sanity checks
    myassert( os.path.exists(ZIP), "7z path invalid" )
    myassert( os.path.isdir(BUPDIR), "Backup folder is invalid" )
    myassert(len(sys.argv) >= 2, "Program called without any commands")

    if sys.argv[1] == "Compress" :
        myassert(len(sys.argv) > 2, "Insufficient parameters")
        sys.argv.pop(0)
        sys.argv.pop(0)
        for file in sys.argv :
            myassert(os.path.exists(file), "Invalid file: " + file)
        Compress(sys.argv)

    elif sys.argv[1] == "Uncompress" :
        myassert(len(sys.argv) == 3, "Invalid number of parameters")
        myassert( os.path.exists(sys.argv[2]), "Zip file does not exist" )
        Uncompress(sys.argv[2])
        
    elif sys.argv[1] == "BackupDir" :
        # Compress the given file(s)
        myassert(len(sys.argv) > 2, "Insufficient parameters")
        sys.argv.pop(0)
        sys.argv.pop(0)
        for file in sys.argv :
            myassert(os.path.exists(file), "Invalid file: " + file)
        zipfile = Compress(sys.argv)
        
        # generate timestamp and move to backup folder
        timestamp = time.strftime("%Y%m%d_%H%M%S_", time.localtime())
        shutil.move( zipfile, os.path.join(BUPDIR, timestamp + os.path.basename(zipfile)) )
    
    elif sys.argv[1] == "BackupFile" :
        myassert(len(sys.argv) == 3, "This operation can take only a single file")
        myassert(os.path.isfile(sys.argv[2]), "Invalid file")
        timestamp = time.strftime("%Y%m%d_%H%M%S_", time.localtime())
        shutil.copy( sys.argv[2], os.path.join(BUPDIR, timestamp + os.path.basename(sys.argv[2])) )

    else :
        myassert(False, "Invalid command")
