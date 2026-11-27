# Helper: send keystrokes to a running VirtualBox VM via set-1 (XT) scancodes.
param(
  [Parameter(Mandatory=$true)][string]$VM,
  [Parameter(Mandatory=$true)][string]$Text,
  [int]$InterKeyMs = 18
)
$VBox = "D:\Oracle\VirtualBox\VBoxManage.exe"

# Base (unshifted) make codes for US layout
$base = @{
 'a'=0x1e;'b'=0x30;'c'=0x2e;'d'=0x20;'e'=0x12;'f'=0x21;'g'=0x22;'h'=0x23;
 'i'=0x17;'j'=0x24;'k'=0x25;'l'=0x26;'m'=0x32;'n'=0x31;'o'=0x18;'p'=0x19;
 'q'=0x10;'r'=0x13;'s'=0x1f;'t'=0x14;'u'=0x16;'v'=0x2f;'w'=0x11;'x'=0x2d;
 'y'=0x15;'z'=0x2c;
 '1'=0x02;'2'=0x03;'3'=0x04;'4'=0x05;'5'=0x06;'6'=0x07;'7'=0x08;'8'=0x09;'9'=0x0a;'0'=0x0b;
 ' '=0x39;'-'=0x0c;'='=0x0d;'`'=0x29;
 '['=0x1a;']'=0x1b;'\'=0x2b;';'=0x27;"'"=0x28;','=0x33;'.'=0x34;'/'=0x35;
}
# Shifted mappings (char -> base key that produces it with shift held)
$shifted = @{
 'A'='a';'B'='b';'C'='c';'D'='d';'E'='e';'F'='f';'G'='g';'H'='h';
 'I'='i';'J'='j';'K'='k';'L'='l';'M'='m';'N'='n';'O'='o';'P'='p';
 'Q'='q';'R'='r';'S'='s';'T'='t';'U'='u';'V'='v';'W'='w';'X'='x';
 'Y'='y';'Z'='z';
 '!'='1';'@'='2';'#'='3';'$'='4';'%'='5';'^'='6';'&'='7';'*'='8';'('='9';')'='0';
 '_'='-';'+'='=';'~'='`';'{'='[';'}'=']';'|'='\';':'=';';'"'="'";'<'=',';'>'='.';'?'='/'
}
$LSHIFT = 0x2a
$CTRL   = 0x1d
$ALT    = 0x38
$ENTER  = 0x1c
$TAB    = 0x0f
$ESC    = 0x01
$BKSP   = 0x0e

function Send-Codes([int[]]$codes){
  if($codes.Count -eq 0){ return }
  $hex = $codes | ForEach-Object { $_.ToString('x2') }
  & $VBox controlvm $VM keyboardputscancode $hex | Out-Null
}

$chars = $Text.ToCharArray()
$i = 0
while($i -lt $chars.Length){
  $c = $chars[$i]
  if($c -eq "`n"){ Send-Codes @($ENTER, 0x80 -bor $ENTER); Start-Sleep -Milliseconds $InterKeyMs; $i++; continue }
  if($c -eq "`t"){ Send-Codes @($TAB, 0x80 -bor $TAB); Start-Sleep -Milliseconds $InterKeyMs; $i++; continue }
  $make = $null; $needShift = $false
  if($base.ContainsKey($c)){ $make = $base[$c] }
  elseif($shifted.ContainsKey($c)){ $needShift = $true; $make = $base[$shifted[$c]] }
  else { $i++; continue } # skip unsupported
  if($needShift){
    Send-Codes @($LSHIFT, $make, (0x80 -bor $make), (0x80 -bor $LSHIFT))
  } else {
    Send-Codes @($make, (0x80 -bor $make))
  }
  Start-Sleep -Milliseconds $InterKeyMs
  $i++
}
