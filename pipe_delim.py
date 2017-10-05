
import csv
import sys

writer = csv.writer(open('songs.csv', 'wb'))
#
#
## genre splitter
#
#with open('split.csv', 'rb') as csvfile:
#    spamreader = csv.reader(csvfile, delimiter=',')
#    #print spamreader
#    for x in spamreader:
#        #print x
#        if "|" in x[2]:
#            mini_genre_list = x[2].split("|")
#            mini_genre_list_count = len(mini_genre_list)
#            for i in range(0,mini_genre_list_count):
#                #print i
#                if i == 0:
#                    new_record = [x[0],x[1],mini_genre_list[i],x[3],x[4],x[5],x[6]]
#                    writer.writerow(new_record)
#                    pass
#                else:
#                
#                ### need to make sure the first record inserted has all the other data related to it
#
#                    new_record = [x[0],"",mini_genre_list[i],"","","",""]
#                    writer.writerow(new_record)
#
#        else:
##print x
#            writer.writerow(x)
##print "hi"
#

### composer split

#with open('split.csv', 'rb') as csvfile2:
#    genre_reader = csv.reader(csvfile2,delimiter = ',')
#    for row in genre_reader:
#        composer = row[4]
#        if "|" in composer:
#            composer_list = composer.split("|")
#            composer_list_count = len(composer_list)
#            for i in range(0,composer_list_count):
#                if i == 0:
#                    new_record = [row[0],row[1],row[2],row[3],composer_list[i].strip(),row[5],row[6]]
#                else:
#                    new_record = [row[0],"","","",composer_list[i].strip(),"",""]
##print new_record
#                writer.writerow(new_record)
#        else:
##print row
#            writer.writerow(row)



with open('split.csv', 'rb') as csvfile2:
    genre_reader = csv.reader(csvfile2,delimiter = ',')
    for row in genre_reader:
        lyricist = row[5]
        print lyricist
        if "|" in lyricist:
            lyricist_list = lyricist.split("|")
            print lyricist_list
            lyricist_list_count = len(lyricist_list)
            print lyricist_list[0]
            for i in range(0,lyricist_list_count):
            
                if i == 0:
                    new_record = [row[0],row[1],row[2],row[3],row[4],lyricist_list[i].strip(),row[6]]
                else:
                    new_record = [row[0],"","","","",lyricist_list[i].strip(),""]
                print new_record
#print new_record
                writer.writerow(new_record)
        else:
            writer.writerow(row)
##print row
##writer.writerow(row)



















