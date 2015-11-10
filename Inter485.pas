unit Inter485;

interface

const
  INT485_MAX_BLK_SIZE = 52;
  INT485_MAX_BLK_CNT  = 255;

type
//  TBlocksData = array[0..(INT485_MAX_BLK_CNT*INT485_MAX_BLK_SIZE)-1] of Byte;
  TBlocksData = array[0..53*255] of Byte;
  TShiftsData = array[0..INT485_MAX_BLK_CNT] of Integer;

function CreateCard(
  Number: Byte;                 //Card number: 1..4
  Address: Byte;                //Card net address: 0..255
  Irq: Byte;                    //Irq use: 0 => don't use, 5,7,9,10 => use
  Speed: Integer;               //Speed: 1200, 2400, 4800, 9600, 19200, 172800
  TimeOut: Integer              //TimeOut: 75 <= master, 100 <= slave
): Integer; stdcall;            //Result: 0 => OK
                                //        else FAIL

function FreeCard(
  Number: Byte                  //Card number: 1..4
): Integer; stdcall;

function Connect(
  Number: Byte;                 //Card number: 1..4
  Mode: Byte;                   //Mode: 0 => slave, 1 => master
  Address: Byte;                //Card net address to connect: 0..255
  const SndBlocks: TBlocksData; //Data to send
  const SndShifts: TShiftsData; //Block shifts in data to send
  SndNmb: Byte;                 //Block count want send
  var SndNumber: Byte;          //Block count really sent
  var RcvBlocks: TBlocksData;   //Data to receive
  var RcvShifts: TShiftsData;   //Block shifts in data to receive
  var RcvNumber: Byte           //Block count really received
): Integer; stdcall;            //Result: 0 => OK (only master mode)
                                //        7 => possibly OK
                                //        8 => not OK
                                //        else FAIL

function ReadID(
  Number: Byte;                 //Card number: 1..4
  Byffer: Pointer               //Pointer to a 8 bytes buffer
): Integer; stdcall;            //Result: 0 => OK
                                //        else FAIL

function InitCard(
  Number: Byte;                 //Card number: 1..4
  Irq: Byte;                    //Irq use: 0 => don't use, 5,7,9,10 => use
  Speed: Integer;               //Speed: 1200, 2400, 4800, 9600, 19200, 172800
  TimeOut: Integer              //TimeOut: 75 <= master, 100 <= slave
): Integer; stdcall;            //Result: 0 => OK
                                //        else FAIL

implementation

const
  API485 = '485.dll';

function CreateCard; external API485 name 'CreateCard';
function FreeCard;   external API485 name 'FreeCard';
function Connect;    external API485 name 'Connect';
function ReadID;     external API485 name 'ReadID';
function InitCard;   external API485 name 'InitCard';

end.

