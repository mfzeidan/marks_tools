


cisco_string = []
import csv


#array_to_grab = 'Cisco	CISCO2921-SEC/K9	Cisco 2921 Security Bundle w/SEC license PAK	1	 $3,097.49 	 $136.07 	 $42.40 	 $295.00 	916331	916336	916332	916333	RTRGT'



with open('Verizon Cisco Hardware.csv', 'r') as f:
    reader = csv.reader(f)
    for row in reader:
        print row
        #
        #list_array = list_array.split("\t")
        #print list_array
        #print x
        #x+=1
        #print row
        line_item_1 = row[0], row[1], row[2], row[4].strip(), row[8], row[12]
        line_item_2 = row[0], row[1], row[2], row[5].strip(), row[9], row[12]
        line_item_3 = row[0], row[1], row[2] , row[6].strip(), row[10], row[12]
        line_item_4 = row[0], row[1], row[2] , row[7].strip(), row[11], row[12]
        #print line_item_1
        #print line_item_2
        #print line_item_3
        #print line_item_4
        saveFile = open('coast_guard_v2.csv','a')
        saveFile.write(str(line_item_1))
        saveFile.write('\n')
        saveFile.write(str(line_item_2))
        saveFile.write('\n')
        saveFile.write(str(line_item_3))
        saveFile.write('\n')
        saveFile.write(str(line_item_4))
        saveFile.write('\n')
        saveFile.close()

    print "Write Complete"

#line_item_1 =  list_array[0], list_array[1], list_array[2] , list_array[4].strip(), list_array[8], list_array[12]
#line_item_2 = list_array[0], list_array[1], list_array[2] , list_array[5].strip(), list_array[9], list_array[12]
#line_item_3 = list_array[0], list_array[1], list_array[2] , list_array[6].strip(), list_array[10], list_array[12]
#line_item_4 = list_array[0], list_array[1], list_array[2] , list_array[7].strip(), list_array[11], list_array[12]

#print line_item_1
#print line_item_2
#print line_item_3
#print line_item_4