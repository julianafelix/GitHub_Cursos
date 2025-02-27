unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Button2: TButton;
    Button1: TButton;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  nNumberOfBytesToRead = 10;
  //nNumberOfBytesToRead = 8192; {8KB}
  vFilePath = 'C:\Temp\Test1.txt';
  //vFilePath = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQL2019\MSSQL\DATA\master.mdf';
var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  lpNumberOfBytesRead:LongWord;
  hFile: THandle;
  DataFileBuffer: array [0..nNumberOfBytesToRead -1] of AnsiChar;
  str1: string;
  RetSize, UpperWord:DWORD;
  lDistanceToMove: Integer;
begin
  try
    try
      Memo1.Clear;
      str1 := '';
      
      // Abre o arquivo sem especificar FILE_FLAG_OVERLAPPED pra
      // informar que queremos um SYNC I/O...
      // CreateFile n�o � igual a "criar um arquivo", ele cria um handle/pointer para
      // cria��o de um arquivo ou abertura de um arquivo existente...
      hFile := CreateFile(vFilePath,
                          GENERIC_READ,
                          FILE_SHARE_READ or FILE_SHARE_WRITE,
                          nil,
                          OPEN_EXISTING,
                          FILE_ATTRIBUTE_NORMAL,
                          0);
  
      // Se o handle for inv�lido, disparar uma exce��o
      if hFile = INVALID_HANDLE_VALUE then
        raise Exception.Create('Deu ruim na hora de rodar o CreateFile');

      // Zerando vari�veis
      // lpNumberOfBytesRead ir� receber a informa��o de quantos bytes foram lidos
      lpNumberOfBytesRead := 0;

      // Pegando tamanho do arquivo via GetFileSize...
      // Vou precisar dessa informa��o pra saber onde posicionar a leitura
      RetSize := GetFileSize(hFile, @UpperWord);

      // Calculando a posi��o da leitura com base no arquivo - o n�mero de bytes que quero ler
      lDistanceToMove := RetSize - nNumberOfBytesToRead;

      // Posicionando o ponteiro no arquivo
      SetFilePointer(hFile, lDistanceToMove, nil, FILE_BEGIN);


      // Gerando leitura
      // Resultado ficar� no DataFileBuffer
      ReadFile(hFile, DataFileBuffer, nNumberOfBytesToRead, lpNumberOfBytesRead, nil);

      // E como o SQL faria uso disso pra posicionar uma leitura quando ele quer ler uma p�gina?

      // Se o n�mero de bytes lidos for maior que zero, continua a leitura
      while (lpNumberOfBytesRead > 0) do
      begin
        str1 := str1 + DataFileBuffer;
        ReadFile(hFile, DataFileBuffer, nNumberOfBytesToRead, lpNumberOfBytesRead, nil);
      end;

      // Exibe
      Memo1.Lines.Add(Str1);
    except
      On E : Exception do
        ShowMessage(E.Message);
    end;
  finally
     CloseHandle(hFile);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  lpNumberOfBytesRead: LongWord;
  hFile: THandle;
  DataFileBuffer: array [0..nNumberOfBytesToRead -1] of AnsiChar;
  lDistanceToMove: Integer;
  ReadFileResult: Boolean;
begin
  try
    try
      // Abre o arquivo sem especificar FILE_FLAG_OVERLAPPED pra
      // informar que queremos um SYNC I/O...
      // CreateFile n�o � igual a "criar um arquivo", ele cria um handle/pointer para
      // cria��o de um arquivo ou abertura de um arquivo existente...
      hFile := CreateFile(vFilePath,
                          GENERIC_READ,
                          FILE_SHARE_READ or FILE_SHARE_WRITE,
                          nil,
                          OPEN_EXISTING,
                          FILE_ATTRIBUTE_NORMAL,
                          0);
  
      // Se o handle for inv�lido, disparar uma exce��o
      if hFile = INVALID_HANDLE_VALUE then
        raise Exception.Create('Deu ruim na hora de rodar o CreateFile');

      // Zerando vari�veis
      // lpNumberOfBytesRead ir� receber a informa��o de quantos bytes foram lidos
      // no ReadFIle...
      lpNumberOfBytesRead := 0;
      memo1.Clear;

      // Preenche o array que ir� receber os dados lidos com chars...
      FillChar(DataFileBuffer, SizeOf(DataFileBuffer), 0);


      // Zerando vari�vel que ser� utilizada para
      // posicionar onde ser� feita a leitura no arquivo... 
      lDistanceToMove := 0;

       // Utilizando SetFilePointer para posicionar a leitura
      // no come�o (FILE_BEGIN e lDistanceToMove = 0) do arquivo 
      SetFilePointer(hFile, lDistanceToMove, nil, FILE_BEGIN);

      // using nil to lpOverlapped because I want a Sync I/O...
      // Chamando ReadFile para executar a leitura...
      // DataFileBuffer � o Array AnsiChar que ir� receber o resultado da leitura
      // nNumberOfBytesToRead � a quantidade de bytes que quero Ler ... (tamanho do I/O)
      // lpNumberOfBytesRead recebe o resultado da quantidade de bytes lidos...
      // nil � o par�metro que eu devo utilizar no caso de uma leitura overllaped (async)
      // como essa � uma leitura sync, n�o preciso passar nada...
      ReadFileResult := ReadFile(hFile, DataFileBuffer, nNumberOfBytesToRead, lpNumberOfBytesRead, nil);

      // Se ReadFileResult for false, deu algum erro no ReadFile...
      if ReadFileResult = false then
        raise Exception.Create('Deu ruim na chamada da ReadFile... GetLastError() = ' + IntToStr(GetLastError()));

      // Enquanto lpNumberOfBytesRead for maior que zero, ou seja, ReadFile leu alguma coisa
      // Continua a leitura...
      while (lpNumberOfBytesRead > 0) do
      begin
        //Escrevendo o resultado (preenchido em DataFileBuffer) da leitura no Memo
        Memo1.Lines.Add(DataFileBuffer);

        //Importante... estou lendo o arquivo de 10 em 10 caracteres...
        // Se eu continuar a leitura e ler os proximos 10 caracteres, vou ler um tudo, inclusive quebra de linha char(10) e char(13)...
        // se eu quiser pular esses caracteres, posso ajustar a posi��o da leitura posicionando a leitura 2 bytes pra frente...
        // Se o arquivo txt sendo lido n�o tiver quebra de linha, n�o preciso fazer isso...

        //lDistanceToMove := 2;
        // SetFilePointer(hFile, lDistanceToMove, nil, FILE_CURRENT);

        // Continua leitura... pedindo pr�ximos 10 (nNumberOfBytesToRead) caracteres...
        // Vou continuar fazendo isso at� lpNumberOfBytesRead for igual a zero...
        ReadFile(hFile, DataFileBuffer, nNumberOfBytesToRead, lpNumberOfBytesRead, nil);
      end;
    except
      On E : Exception do
        ShowMessage(E.Message);
    end;
  finally
     CloseHandle(hFile);
  end;

  {
    E pra ler 8KB igual no SQL, como eu faria?
  }

end;

end.
