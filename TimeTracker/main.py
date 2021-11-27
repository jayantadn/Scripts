# custom utility functions
def myassert(cond, msg, raise_excep = False) :
    if not cond :
        print( "ERROR: " + msg )
        if raise_excep :
            input("Press <enter> to see details.")
            raise
        else :
            input("Press <enter> to exit...")
            os.abort()

def clearscr() :
    if os.name =='posix' :
        os.system('clear')
    elif os.name =='nt' :
        os.system('cls')
    else :
        pass

# import modules
try :
    import os
    import configparser
    from datetime import *
    import json
    import prettytable 
except :
    myassert( False, "Could not import some modules. Use \'pip install <module>\' to install them", True )

# import internal modules
from Menu import *

# reading config and database files globally, as its required for all functions
config = configparser.ConfigParser()
config.read('config.ini')
dbfile = open( config['DEFAULT']['TIMEDB'], 'r' )
timedb = json.loads( dbfile.read() )
dbfile.close()    

# display the current statistics
def show_stats() :
    global config
    global timedb

    # print current week data
    table = prettytable.PrettyTable(["Date", "Day", "Work Day", "Duration"])
    # table.add_row( ["22-10-22", "Fri", 1, 34 ] )
    # print(table)
    ( _, curweek, _) = datetime.today().isocalendar()

    # calculate deficit hours
    ndays = 0
    acttd = timedelta(0)
    flgTimerStarted = False
    for entry in timedb :
        # calculate number of working days
        ndays += entry['workday']

        # calculate total
        td = timedelta(0)
        for tim in entry['timestamps'] :
            (h, m, s) = tim['start'].split(":")
            start = datetime.combine(date.today(), time(int(h),int(m),int(s)))
            if tim['end'] is not None :
                (h, m, s) = tim['end'].split(":")
                end = datetime.combine(date.today(), time(int(h),int(m),int(s)))
                td += (end - start)
            else :
                flgTimerStarted = True
                end = datetime.today()
                td += (end - start)
        acttd += td 

        # collect data for current week
        (y, mm, s) = entry['date'].split("-")
        dat = datetime( int(y), int(mm), int(s) )
        ( _, week, _) = dat.isocalendar()
        if week == curweek :
            table.add_row( [ entry['date'], dat.strftime("%a"), entry['workday'], f"{td.seconds/3600:.2f}" ] )

    exphrs = ndays * float( config['DEFAULT']['DAILYEFFORT'] )
    acthrs = acttd.seconds/3600
    defhrs = exphrs - acthrs
    clearscr()
    print(table)
    print(f"Deficit hours: {defhrs:.2f}")
    print(f"Timer running: {flgTimerStarted}")

def start_timer() :
    global config
    global timedb

    # modify contents
    tod = datetime.today().strftime("%Y-%m-%d")
    idx = None
    for i in range( len(timedb) ) :
        if tod == timedb[i]['date'] :
            idx = i
            break
    if idx is None :
        datentry =     {
            "date": tod,
            "workday": 1,
            "timestamps": [],
            "correction" : 0
        }
        idx = len(timedb)
        timedb.append(datentry)
    timentry = {
          "start": datetime.now().strftime("%H:%M:%S"),
          "end": None
        }
    timedb[idx]['timestamps'].append(timentry)
    
    # write back
    file = open( config['DEFAULT']['TIMEDB'], 'w' )
    file.write( json.dumps(timedb, indent=4) )
    file.close()
    show_stats()

def stop_timer() :
    global config
    global timedb

    # modify contents
    tod = datetime.today().strftime("%Y-%m-%d")
    for i in range( len(timedb) ) :
        if tod == timedb[i]['date'] :
            for j in range( len(timedb[i]['timestamps']) ) :
                if timedb[i]['timestamps'][j]['end'] is None :
                    timedb[i]['timestamps'][j]['end'] = datetime.now().strftime("%H:%M:%S")
                    break
            break
    
    # write back
    file = open( config['DEFAULT']['TIMEDB'], 'w' )
    file.write( json.dumps(timedb, indent=4) )
    file.close()
    show_stats()

def edit_timer() :
    global config
    global timedb

    # tod = datetime.today().strftime("%Y-%m-%d")
    # for entry in timedb :
    #     if tod == entry['date'] :
    #         idx = len( entry['timestamps'] ) - 1
    #         tim = entry['timestamps'][idx]
    #         if tim['end'] is None :
    #             newtime = input(f"Old start time = {tim['end']} \tEnter new start time = ")
    #             tim['end'] = newtime
    #         else :
    #             input(f"Old end time = {tim['end']} \tEnter new end time = ")
    #         break
    # print(timedb)

def edit_workday() :
    pass

def show_menu() :
    menu = Menu()
    menu.add( MenuItem( "Start Timer", start_timer ) )
    menu.add( MenuItem( "Stop Timer", stop_timer ) )
    menu.add( MenuItem( "Refresh", show_stats ) )
    menu.add( MenuItem( "Edit timer", edit_timer ) )
    menu.add( MenuItem( "Edit working day", edit_workday ) )
    while True: menu.show()

def main() :
        show_stats()
        show_menu()

if __name__ == "__main__":
    try :
        main()
    except SystemExit :
        pass
    except KeyboardInterrupt :
        pass
    except:
        myassert( False, "An exception has occurred.", True )            
