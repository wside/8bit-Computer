name = input("Name of File:")
text_file = open(name)
lines = text_file.read().split('\n')
text_file.close()

name += "_Output"
text_file = open(name, 'w')

def Reg(s): #takes the register name, returns the binary representation
    if (s == "$0"):
        return "000"
    elif (s == "$gp"):
        return "001"
    elif (s == "$sp"):
        return "010"
    elif (s == "$ra8"):
        return "011"
    elif (s == "$r0"):
        return "100"
    elif (s == "$r1"):
        return "101"
    elif (s == "$r2"):
        return "110"
    elif (s == "$r3"):
        return "111"
    else:
        return "error"

varname = []
varaddress = []
i = int(0) #byte of output
x = int(0) #line of input

while lines[x][0]=="-": #.data section
    
    words = lines[x].split(" ")
    
    if (words[0].lower() == "-string"):
        varname.append(words[1])
        varaddress.append(int(i/2))
        
        for ch in words[2]:
            text_file.write('{0:08b}'.format(ord(ch)))
            i = i+1
            
            if (i%2 == 0):
                text_file.write("\n")
                
        x = x+1
        text_file.write("00000000") #end string with newline
        i = i+1
        
        if (i%2 == 1): #if odd number of bytes printed, print 00000000 to make it even
            text_file.write("00000000\n")
            i = i+1
        else:
            text_file.write("\n")
        
    elif (words[0].lower() == "-int"):
        varname.append(words[1])
        varaddress.append(int(i/2))
        text_file.write("00000000"+ words[2]+"\n") #8 bit binary number in 16 bits
        x = x+1
        i = i+2
        
        
i = int(i/2) #change from byte of output to line of output


if (i>=256):
    print ("Data too large")
    exit

text_file.write("@100\n") #tells verilog that the next section is the instruction section

i = 256
    
while (lines[x].split(" ")[0].lower() != "eof"): #instruction section

    words = lines[int(x)].split(" ")
    new_line = "" 
    word = ""
    word += words[0].lower() #lowercase
    
    if (word == "add"):
        new_line += "00"
        new_line += Reg(words[1])
        new_line += Reg(words[2])
        new_line += "00000000"
        
    if (word == "nand"):
        new_line += "01"
        new_line += Reg(words[1])
        new_line += Reg(words[2])
        new_line += "00000000"
 
    if (word == "slt"):
        new_line += "10"
        new_line += Reg(words[1])
        new_line += Reg(words[2])
        new_line += "00000000"
        
    if (word == "move"):
        new_line += "11000"
        new_line += Reg(words[1])
        new_line += "00000000"
        
    if (word == "srl"):
        new_line += "11001"
        new_line += '{0:03b}'.format(int(words[1]))[-3:]
        new_line += "00000000"
        
    if (word == "jrra"):
        new_line += "11010"
        a = Reg(words[1])
        
        if (a=="error"):
            new_line += words[1]
            
        else:
            new_line += a
            
        new_line += "00000000"
        
    if (word == "jal"):
        new_line += "11011"
        new_line += '{0:011b}'.format(int(words[1]))[-11:]
        
    if (word == "sw"):
        new_line += "11100"
        new_line += Reg(words[1])
        new_line += Reg(words[2])
        new_line += words[3]
        
    if (word == "addi"):
        new_line += "11101"
        new_line += Reg(words[1])
        new_line += words[2]
        
    if (word == "lw"):
        new_line += "11110"
        new_line += Reg(words[1])
        new_line += Reg(words[2])
        new_line += words[3]
        
    if (word == "beq"):
        new_line += "11111"
        new_line += Reg(words[1])
        new_line += Reg(words[2])
        new_line += words[3]
        new_line += Reg(words[4])

    if (word == "printstr"):
        new_line += "11101000"
        new_line += '{0:b}'.format(varaddress[varname.index(words[1])]).zfill(8)
        new_line += "1101000100000000"
        i+=1
        
    if (word == "printint"):
        new_line += "11101000"
        new_line += '{0:b}'.format(varaddress[varname.index(words[1])]).zfill(8)
        new_line += "1101001000000000"

    if (word == "la"):
        new_line += "11101000"
        new_line += '{0:b}'.format(varaddress[varname.index(words[1])]).zfill(8)

    text_file.write(new_line[8:16])
    text_file.write(new_line[0:8])
    text_file.write("\n")
    
    if (word == "printstr" or word == "printint"): #second line of two line pseudoinstructions
        text_file.write(new_line[24:32])
        text_file.write(new_line[16:24])
        text_file.write("\n")
        i+=1
    
    if (i>=2048):
        print ("Instructions too long")
        exit
    x+=1
    i+=1


text_file.close()

