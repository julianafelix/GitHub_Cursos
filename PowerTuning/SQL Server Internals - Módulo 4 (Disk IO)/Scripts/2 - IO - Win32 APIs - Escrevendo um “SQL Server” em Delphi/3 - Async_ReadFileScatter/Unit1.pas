unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Math;

type
  TForm1 = class(TForm)
    Memo3: TMemo;
    Button4: TButton;
    ProgressBar1: TProgressBar;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    edtfPath: TEdit;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

// Estrutura do FILE_SEGMENT_ELEMENT em C++
//typedef union _FILE_SEGMENT_ELEMENT {
//    PVOID64 Buffer;
//    ULONGLONG Alignment;
//}FILE_SEGMENT_ELEMENT, *PFILE_SEGMENT_ELEMENT;
type
  FILE_SEGMENT_ELEMENT = record
    Buffer: Pointer;
    Alignment: Cardinal;
  end;

pFILE_SEGMENT_ELEMENT = ^FILE_SEGMENT_ELEMENT;

function ReadFileScatter(hFile: THandle; aSegmentArray: pFILE_SEGMENT_ELEMENT;
    nNumberOfBytesToRead: LongWord; lpReserved: PLongWord; lpOverlapped: POverlapped): LongBool;
    StdCall; External 'Kernel32.dll' Name 'ReadFileScatter';

function WriteFileGather(hFile: THandle; aSegmentArray: pFILE_SEGMENT_ELEMENT;
  nNumberOfBytesToWrite: LongWord; lpReserved: PLongWord; lpOverlapped: POVERLAPPED): LongBool;
  StdCall; External 'Kernel32.dll' Name 'WriteFileGather';

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button4Click(Sender: TObject);
var
  BytesReturnedFromReadFileScatter, T, dummy: Cardinal;
  i, ii, SectorSize, nNumberOfBytesToRead, FileSize: Integer;
  vSYSTEM_INFO: TSystemInfo;
  fHandleInput: THandle;
  vOverlappedRead: TOverlapped;
  vFileSegmentElement: Array of FILE_SEGMENT_ELEMENT;
  Debug, vGetOverlappedResult, ReadFileScatterResult: Boolean;
  fPath, BufferResultString: String;
  BufferResult: PChar;
begin
  Memo3.Clear;
  Memo3.Lines.Add('Come�ando o ReadFileScatter');

  Debug := True;
  T := GetTickCount;

  fPath := edtfPath.Text;
  fHandleInput := CreateFile(PChar(fPath), GENERIC_READ, FILE_SHARE_READ, nil,
    OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN or FILE_FLAG_NO_BUFFERING or FILE_FLAG_OVERLAPPED, 0);
        
  // Se o handle for inv�lido, disparar uma exce��o
  if fHandleInput = INVALID_HANDLE_VALUE then
    raise Exception.Create('Deu ruim na hora de rodar o CreateFile... GetLastError() = ' + IntToStr(GetLastError()));
      
      
  FileSize := GetFileSize(fHandleInput, @dummy);
  ProgressBar1.Max := FileSize;
  ProgressBar1.Position := 0;
  Application.ProcessMessages;
      
  // Pra simplificar vou utilizar o "Bytes Per Sector" fixo de 512...
  // O ideal seria chamar a GetFileInformationByHandleEx pra pegar o PhysicalBytesPerSectorForAtomicity
  SectorSize := 512;

  // ReadFileScatter requer que o a quantidade de bytes lidos
  // seja um m�ltiplo do SectorSize do disco (normalmente entre 512-4096 bytes)...
  // Se eu tentar usar um valor que n�o � m�ltiplo do SectorSize do disco,
  // vou tomar um erro ERROR_INVALID_PARAMETER
  nNumberOfBytesToRead := StrToInt(Edit1.Text);

  // Identificando o �memory page size� do Windows
  // GetSystemInfo, vai preencher o dwPageSize na estrutura SYSTEM_INFO
  GetSystemInfo(vSYSTEM_INFO);

  // Windows utiliza blocos de 4KB de mem�ria...
  // Chamando a GetSystemInfo s� pra confirmar os 4096 bytes de "Memory Page Size"
  // Esse valor � importante porque pra usar a ReadFileScatter ou WriteFileGather
  // A mem�ria informada precisa estar alinhada com o Windows, ou seja,
  // N�o posso passar um array de mem�ria de 3KB ou 9KB pq vai dar erro...
  // A mem precisa ser um multiplo do dwPageSize
  // Com base no tamanho do "memory page size", especifico a quantidade
  // de FileSegmentElement que vou precissar no Array
  // + 1 no final, � pq o Array sempre precisa ter um elemento sobrando
  // pro "terminating NULL"
  // Ex, se quero ler 65536 bytes (64KB), preciso de (65536 / 4096) = 16 elementos + 1 pro NULL
  SetLength(vFileSegmentElement, (nNumberOfBytesToRead div vSYSTEM_INFO.dwPageSize) + 1);

  // FillMemory inicializa a mem�ria usando o "byte value" = "0"
  FillMemory(@vFileSegmentElement[0], Length(vFileSegmentElement) * SizeOf(FILE_SEGMENT_ELEMENT), 0);
  
  // Alocando a mem�ria que ser� utilizada pra ler os dados do arquivo...
  // Lembrando, a mem�ria utilizada precisa estar alinhada com o �memory page size� do Windows.
  // Windows l� e escreve na mem�ria em blocos de 4KB.
  // VirtualAlloc j� faz a aloca��o utilizando o �memory page size�
  vFileSegmentElement[0].Buffer := VirtualAlloc(nil, nNumberOfBytesToRead, MEM_COMMIT, PAGE_READWRITE);

  for i := 1 to High(vFileSegmentElement) - 1 do
    vFileSegmentElement[i].Buffer := Pointer(Cardinal(vFileSegmentElement[i - 1].Buffer) + vSYSTEM_INFO.dwPageSize);

  // �ltimo elemento � pro "Terminating NULL"
  vFileSegmentElement[High(vFileSegmentElement)].Buffer := nil;
      
  // Inicializando as estruturas Overlapped usando o "byte value" = "0"
  FillMemory(@vOverlappedRead, SizeOf(vOverlappedRead), 0);
      
  i := 0;
  BytesReturnedFromReadFileScatter := 0;
  repeat
    BufferResultString := '';
    // Especificando o Offset na estrutura Overlapped
    vOverlappedRead.OffsetHigh := 0;
    vOverlappedRead.Offset := Int64(nNumberOfBytesToRead) * i;

    // Chamando a ReadFileScatter... Os dados lidos ser�o armazenados no array de FileSegmentElement
    ReadFileScatterResult := ReadFileScatter(fHandleInput, @vFileSegmentElement[0], nNumberOfBytesToRead, nil, @vOverlappedRead);

    // Se ReadFileScatter for false, deu algum erro no ReadFileScatter...
    if ReadFileScatterResult = False then
      ReadFileScatterResult := GetLastError() = ERROR_IO_PENDING;
    if ReadFileScatterResult = False then
      raise Exception.Create('Deu ruim na chamada da ReadFileScatter... GetLastError() = ' + IntToStr(GetLastError()));

    vGetOverlappedResult := GetOverlappedResult(fHandleInput, vOverlappedRead, BytesReturnedFromReadFileScatter, True);
    if (vGetOverlappedResult = false) then
    begin
      if GetLastError() = ERROR_HANDLE_EOF then
      begin
        Break;
      end
      else
        raise Exception.Create('Deu ruim na chamada da GetOverlappedResult... GetLastError() = ' + IntToStr(GetLastError()));;
    end;

    // Valida se chegou no final do arquivo
    if (BytesReturnedFromReadFileScatter = 0) or (GetLastError() = ERROR_HANDLE_EOF) then
    begin
      Break;
    end;

    if Debug then
    begin
      BufferResult := PChar(vFileSegmentElement[0].Buffer);
      for ii := 0 to 9 do
        BufferResultString := BufferResultString + BufferResult[ii];

      Memo3.Lines.Add(BufferResultString);
    end;

    ProgressBar1.Position := ProgressBar1.Position + BytesReturnedFromReadFileScatter;
    Application.ProcessMessages;
    Inc(i);
  Until (BytesReturnedFromReadFileScatter <= 0);

  //eof.EndOfFile.QuadPart := FinalSize;
  //if not SetFileInformationByHandle(fHandleOutput, FileEndOfFileInfo, @eof, SizeOf(eof)) then RaiseLastOSError;

  CloseHandle(fHandleInput);
  VirtualFree(vFileSegmentElement, 0, MEM_RELEASE);

  T := Max(GetTickCount - T, 1);
  Memo3.Lines.Add('Termino do ReadFileScatter');
  Memo3.Lines.Add(Format('nReads = %d - ms = %d', [i, T]));
end;


end.
