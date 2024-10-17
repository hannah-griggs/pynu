import pandas as pd
import argparse

# Parser
parser = argparse.ArgumentParser()
parser.add_argument('window', help="Time delay window around event in seconds")
parser.add_argument('chunk', help = "Chunk number")
parser.add_argument('time', help="T90 for GRB")
args = parser.parse_args()

# Chunk number
chunk=int(args.chunk)

def check_time_within_window(csv_file, gps_time, time_window):
    # Load the CSV file into a DataFrame
    df = pd.read_csv(csv_file)

    # Calculate the time difference and check if within the window
    df['Time Difference'] = abs(df['End Time'] - gps_time)
    within_window = df[df['Time Difference'] <= time_window]

    # Return rows where the 'End Time' is within the time window
    if not within_window.empty:
        return within_window
    else:
	return "No triggers found within the given time window. Skip this event."

# Main:

csv_file = '/home/hannah.griggs/nu/pynu_tests/o2grbs/results/outputallskychunk{}_F$
gps_time = float(args.time)
time_window = float(args.window)

result = check_time_within_window(csv_file, gps_time, time_window)
print(result)

