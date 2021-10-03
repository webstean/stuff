##### Admin Kit to build winpe
choco install windows-adk -y 
choco install windows-adk-winpe -y 

List disk
select disk X    (where X is your USB drive)
clean
create partition primary size=2048
active
format fs=FAT32 quick label="WinPE"
assign letter=P
create partition primary
format fs=NTFS quick label="Images"
assign letter=I  
Exit

