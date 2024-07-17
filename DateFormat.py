import csv

#As Original Data scraped from Formula 1 website had format of MMM-DD which was
#parsed as MMM-YY by Microsoft Excel, this script converts the dates to
#DD-MMM which is parsed correctly by Excel
with open ('Temp.csv', 'w', newline = '') as g:
    with open ('Formula1.csv', 'r+', newline = '') as f:
        r = csv.reader (f)
        w = csv.writer (g)
        for i in r:
            d = i[0][-2::] + '-' + i[0][:3]
            w.writerow([d, i[1], i[2]])
