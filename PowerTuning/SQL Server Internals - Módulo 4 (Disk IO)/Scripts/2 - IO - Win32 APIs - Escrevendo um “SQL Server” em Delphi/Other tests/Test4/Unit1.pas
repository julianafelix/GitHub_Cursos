unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  nNumberOfBytesToRead = 10;
  nThreads = 8 - 1;
  vFilePath = 'C:\Temp\Test3.txt';
  //vFilePath = 'C:\DBs\northwnd.mdf';

type
  TMyArray = array [0..nNumberOfBytesToRead - 1] of AnsiChar;


type
  TDataFileBufferPointers = record
   DataFileBufferPointer: array [0..nNumberOfBytesToRead - 1] of AnsiChar;
end;

var
  Form1: TForm1;
  IOCPHandle, FileHandle, CompletionPortThreadID: THandle;
  BufferPointerArray: array [0..nThreads] of TMyArray;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
Var
  OverlappedIOs: array [0..nThreads] of POverLapped;
  hThreadID: THandle;
  ThreadID :Cardinal;
  VarlpNumberOfBytesTransferred, lpNumberOfBytesRead: Cardinal;
  ReadWorked, GetQueuedCompletionStatusResult: Boolean;
  CompletionRoutineTotalBytesTransfered, i, InitialPos: Integer;
  p, pp: Pointer;
  GetLastErrorResult: cardinal;
  
label
  GotoScanFile;
begin
  // Cria completion port com m�ximo de 0(n de threads no PC) threads rodando em simultaneo
  IOCPHandle := CreateIOCompletionPort(INVALID_HANDLE_VALUE, 0, 0, 0);

  FileHandle := CreateFile(vFilePath,
                           GENERIC_READ or GENERIC_WRITE,
                           0,
                           nil,
                           OPEN_EXISTING,
                           FILE_FLAG_OVERLAPPED, //and FILE_FLAG_NO_BUFFERING // Will need to allocate mem first... call VirtualAlloc?
                           0);

  // Se o handle for inv�lido, disparar uma exce��o
  if FileHandle = INVALID_HANDLE_VALUE then
    raise Exception.Create('Deu ruim na hora de rodar o CreateFile');

  // Associar FileHandle com a completion port criada...
  CreateIOCompletionPort(FileHandle,
                         IOCPHandle,
                         0,
                         0);

  InitialPos := 0;

GotoScanFile:

  i:= 0;
  while i <= nThreads do
  begin
    OverlappedIOs[i] := New(POverlapped);
    //DataFileBufferPointer[i] := New();
    
    // Aloca a mem�ria que ser� utilizada pelo Pchar Array DataFileBufferPointer...
    // Aqui � onde os dados lidos no I/O ser�o armazenados...
    //ReadFileRecords[i].DataFileBufferPointer[i] := AllocMem(nNumberOfBytesToRead + 1);

    // Preenche a estrutura vOverlapped com chars...
    // Again, iniciando a area que ser� utilizada na leitura
    //FillChar(ReadFileRecords[i].OverlappedIOs[i], SizeOf(ReadFileRecords[i].OverlappedIOs), 0);
    FillChar(BufferPointerArray[i], SizeOf(BufferPointerArray[i]), 0);

    OverlappedIOs[i].Internal := 0;
    OverlappedIOs[i].InternalHigh := 0;
    OverlappedIOs[i].hEvent := 0;
    OverlappedIOs[i].Offset := (nNumberOfBytesToRead * i) + (InitialPos);
    OverlappedIOs[i].OffsetHigh := 0;
    

    lpNumberOfBytesRead := 0;
    // Inicia leituras...


    ReadWorked := ReadFile(FileHandle,
                           BufferPointerArray[i],
                           nNumberOfBytesToRead,
                           lpNumberOfBytesRead,
                           OverlappedIOs[i]);


    if ReadWorked = False then
      ReadWorked := GetLastError() = ERROR_IO_PENDING;
    if ReadWorked = False then
      raise Exception.Create('Deu ruim na chamada da ReadFileEx... GetLastError() = ' + IntToStr(GetLastError()));

    {
    ThreadID := 0;
    hThreadID := CreateThread(nil,
                              0,
                              0,
                              nil,
                              Cardinal(MinhaThread(i, FileHandle, BufferPointerArray[i], OverlappedIOs[i])),
                              ThreadID);
    }
    
    i := i + 1;
  end;

  i:= 0;
  // Inicia verifica��es para obter retorno do I/O...
  while i <= nThreads do
  begin
    //Call GetQueuedCompletionStatus to wait for notification of completion of a pending receive operation associated with the completion port.
    VarlpNumberOfBytesTransferred := 0;
    GetQueuedCompletionStatusResult := GetQueuedCompletionStatus(IOCPHandle, // Completion port handle
                                                                 VarlpNumberOfBytesTransferred, // Bytes transferred
                                                                 Cardinal(p), // CompletionKey,
                                                                 OverlappedIOs[i], // OVERLAPPED structure
                                                                 INFINITE); // Notification time-out interval
    
    GetLastErrorResult := GetLastError();
    if (GetQueuedCompletionStatusResult = False) and (GetLastErrorResult <> WAIT_TIMEOUT) then
    begin
      //ERROR_HANDLE_EOF = 38
      // Verifica se o erro � ERROR_HANDLE_EOF, se sim, significa que chegamos
      // no final o arquivo...
      if GetLastErrorResult = ERROR_HANDLE_EOF then
        // Adiciona o no Memo pra eu saber que chegou no final do arquivo...
        Memo1.Lines.Add('ERROR_HANDLE_EOF')
      else
        // Se for algum outro erro adiciona no Memo pra eu saber
        raise Exception.Create('Algum outro erro no resultado da GetQueuedCompletionStatusResult, GetLastError() = ' + IntToStr(GetLastErrorResult));

      // Set CompletionRoutineTotalBytesTransfered para zero pra eu saber que n�o
      // preciso continuar a leitura...
      CompletionRoutineTotalBytesTransfered := 0;
      Break;
    end;
    Memo1.Lines.Add(BufferPointerArray[i]);
    i := i + 1;
  end;

  if (GetLastErrorResult <> ERROR_HANDLE_EOF) or (VarlpNumberOfBytesTransferred > 0) then
  begin
    //Memo1.Lines.Add('Not on ERROR_HANDLE_EOF or VarlpNumberOfBytesTransferred > 0... Starting more threads');
    //Memo1.Lines.Add('VarlpNumberOfBytesTransferred = ' + IntToStr(VarlpNumberOfBytesTransferred));

    InitialPos := InitialPos + ( (nThreads + 1) * VarlpNumberOfBytesTransferred );
    Goto GotoScanFile;
  end;
  
  CloseHandle(IOCPHandle);
  CloseHandle(FileHandle);
end;

end.
