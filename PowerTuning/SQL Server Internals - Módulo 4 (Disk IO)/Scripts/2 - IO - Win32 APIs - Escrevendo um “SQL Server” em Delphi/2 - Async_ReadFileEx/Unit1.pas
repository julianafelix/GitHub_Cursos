unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Memo3: TMemo;
    Button4: TButton;
    Panel1: TPanel;
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    procedure InitFileAndSections;
    procedure DoRead(InitialPos: Integer);
    procedure Cleanup;
  public
    { Public declarations }
  end;

type
  NTSTATUS = ULONG;
  {$EXTERNALSYM NTSTATUS}
  PNTSTATUS = ^NTSTATUS;
  {$EXTERNALSYM PNTSTATUS}
  TNTStatus = NTSTATUS;

function HasOverlappedIoCompleted(const lpOverlapped: OVERLAPPED): BOOL;
{$EXTERNALSYM HasOverlappedIoCompleted}

const
  nNumberOfBytesToRead = 10;
  nThreads = 8;
  fPath = 'C:\temp\Test2.txt';
  //fPath = 'E:\Test2.txt';
type
  PCardinal = ^cardinal;
  TCompRoutineRequest = record
    DataFileBufferPointer: array [0..nNumberOfBytesToRead -1] of PChar;
    vOverlapped: OVERLAPPED;
    CompletionRoutine: Pointer;
    BUFPointer: Pointer;
  end;

  TArray_CompletionRoutineRequest = record
    CompletionRoutineRequest: array [0..Pred(nThreads)] of TCompRoutineRequest;
  end;

var
  Form1: TForm1;
  Array_CompRoutineRequest: TArray_CompletionRoutineRequest;
  x: Integer;
  CompletionRoutineResult: String;
  CompletionRoutineTotalBytesTransfered: DWORD;
  WaitArray: array[0..Pred(nThreads)] of THandle;
  vList: TStringList;
  CompletionRoutineResultMemo: TMemo;
  FileHandle: THandle;

implementation

{$R *.dfm}

function HasOverlappedIoCompleted(const lpOverlapped: OVERLAPPED): BOOL;
begin
  Result := NTSTATUS(lpOverlapped.Internal) <> STATUS_PENDING;
end;

// Rotina que ser� chamada quando o evento for sinalizado...
procedure CompletionRoutine(ErrorCode, BytesTransferred: DWORD; Overlapped: OVERLAPPED); stdcall;
Var
 EventID: Integer;
begin
  // Se ErrorCode for 0, ent�o leitura est� ok...
  if ErrorCode = 0 then
  begin
    // Qual n�mero do Evento(poderia ser uma thread/threadId) que iniciou essa leitura?
    EventID := vList.IndexOf(IntToStr(Overlapped.hEvent));

    // L� os dados do DataFileBufferPointer (Pchar array) lido no ReadFileEx da thread em quest�o
    CompletionRoutineResult := '';
    CompletionRoutineResult := Array_CompRoutineRequest.CompletionRoutineRequest[EventID].DataFileBufferPointer[EventID];

    // Salva a informa��o lida no CompletionRoutineResultMemo
    CompletionRoutineResultMemo.Lines.Add(CompletionRoutineResult);

    // Limpa memoria utilizada por esse Pchar array
    FreeMem(Array_CompRoutineRequest.CompletionRoutineRequest[EventID].DataFileBufferPointer[EventID]);
    
    // Fecha o handle do evento
    CloseHandle(Overlapped.hEvent);
  end
  else
  begin
    // Informa que CompletionRoutineTotalBytesTransfered � igual a zero,
    // pra informar que j� podemos terminar a leitura
    CompletionRoutineTotalBytesTransfered := 0;
  end;
end;

procedure TForm1.InitFileAndSections;
begin
  // Abre o arquivo utilizando o FILE_FLAG_OVERLAPPED pra
  // informar que queremos um ASYNC I/O...
  // CreateFile n�o � igual a "criar um arquivo", ele cria um handle/pointer para
  // cria��o de um arquivo ou abertura de um arquivo existente...
  FileHandle := CreateFile(fPath,
                           GENERIC_READ or GENERIC_WRITE,
                           0,
                           nil,
                           OPEN_EXISTING,
                           FILE_FLAG_OVERLAPPED, //and FILE_FLAG_NO_BUFFERING // Precisaria alocar a mem�ria (call VirtualAlloc?)... Demo ia ficar mto complexa ent�o n�o estou utilizando esse flag...
                           0);
                            
  // Se o handle for inv�lido, disparar uma exce��o
  if FileHandle = INVALID_HANDLE_VALUE then
    raise Exception.Create('Deu ruim na hora de rodar o CreateFile');
end;

procedure TForm1.DoRead(InitialPos: Integer);
var
  ReadWorked: boolean;
  vEvent: THandle;
  VarlpNumberOfBytesTransferred: DWORD;
  GetOverlappedResult1, HasOverlappedIoCompletedResult: boolean;
  WaitForSingleObjectResult: Cardinal;
label
  GotoScanFile;

begin

  // Criando o Memo interno que receber� os dados da rotina CompletionRoutineResul
  if CompletionRoutineResultMemo = nil then
  begin
    CompletionRoutineResultMemo := TMemo.Create(self);
    CompletionRoutineResultMemo.Parent := Form1.Panel1;
  end;

GotoScanFile:

  // Toda vez que DoRead � chamada, limpo a vList pra guardar
  // apenas a informa��o dos eventos criados nessa chamada...
  if vList = nil then
    vList := TStringList.Create
  else
    vList.Clear;

  // Roda o ReadFileEx para cada nThreads (constante global)
  for x := 0 to Pred(nThreads) do
  begin
    // Minha estrutura de "completion routine request" � igual a do SQL Server.... ou seja,
    // Tem info da estrutura Overlapped
    // + o ponteiro pra "Completion Routine" que ser� chamada
    // + um ponteiro pra estrutura BUF
    // e o hEvent com a informa��o do Evento que ser� sinalizado quando o I/O terminar...

    // N�o estou utilizando o BUF, mas no SQL ele teria informa��es sobre
    // PageFile + PageID
    // bpage
    // bstat
    // Latch
    
    Array_CompRoutineRequest.CompletionRoutineRequest[x].BUFPointer := Cardinal(0);

    // Especificando o ponteiro pra completion routine que quero chamar quando o I/O for
    // sinalizado...
    Array_CompRoutineRequest.CompletionRoutineRequest[x].CompletionRoutine := @CompletionRoutine;

    // Aloca a mem�ria que ser� utilizada pelo Pchar Array DataFileBufferPointer...
    // Aqui � onde os dados lidos no I/O ser�o armazenados...
    Array_CompRoutineRequest.CompletionRoutineRequest[x].DataFileBufferPointer[x] := AllocMem(nNumberOfBytesToRead + 1);
    
    // Aqui � importante... Qual offset utilizado na leitura...
    // Offset � a posi��o onde a leitura come�a no arquivo...
    // Ex, considerando um arquivo com 1000 bytes, um offset de 20 indica que a leitura
    // come�a a partir da posi��o 20 no arquivo...
    // O calculo aqui � feito com base em quantos bytes (nNumberOfBytesToRead) quero ler por I/O
    // vezes o n�mero da thread, mais a posi��o inicial (InitialPos)
    // InitialPos � o n�mero de bytes lidos so far... Ou seja,
    // Se na thread 8 o total de bytes lidos deve ser 80 (10 bytes por thread),
    // se n�o chegamos no final do arquivo, mais threads ser�o geradas para continuar a leitura
    // nesse caso as novas threads utiliar�o o InitialPos de 80...
    // Sendo assim o offset da nova thread seria
    // (nNumberOfBytesToRead * x) + (InitialPos) = (10 * 0) + 80 = 80...
    // Offset da pr�xima thread seria: (10 * 1) + 80 = 90... e assim por diante...
    Array_CompRoutineRequest.CompletionRoutineRequest[x].vOverlapped.Offset := (nNumberOfBytesToRead * x) + (InitialPos);

    // Criando um evento que ser� utilizado para sinalizar que o I/O
    // terminou... Esse evento � vinculado a estutura Overlapped
    // vEvent � uma propriedade da Overlapped
    // Quando o I/O terminar o "device driver, no nosso caso o arquivo" sinaliza pra esse evento
    // que isso aconteceu...
    vEvent := CreateEvent(nil, true, false, nil);
    Array_CompRoutineRequest.CompletionRoutineRequest[x].vOverlapped.hEvent := vEvent;

    {
      Nota: Aqui eu criei as estruturas Overlapped com tamanho fixo... e j� aloquei a mem pra
      elas na declara��o no array SectionData...
      Uma otimiza��o que o SQL faz pra essas estruturas � usar a function SetFileIoOverlappedRange:

      "Associates a virtual address range with the specified file handle. This indicates that the kernel should
      optimize any further asynchronous I/O requests with overlapped structures inside this range.
      The overlapped range is locked in memory, and then unlocked when the file is closed.
      After a range is associated with a file handle, it cannot be disassociated."

      Locked in memory, ou seja, "requires locked pages privilege" ...      
    }


    // Pra eu conseguir saber qual thread de um determinado evento
    // adiciono o evento gerado em uma TStringList e depois procuro qua o Index
    // desse evento...
    vList.Add(IntToStr(vEvent));

    // Se deu algum erro na criac�o do evento, j� grita agora...
    if Array_CompRoutineRequest.CompletionRoutineRequest[x].vOverlapped.hEvent = 0 then
      raise Exception.Create('Deu alguma zica na cria��o do evento...');

    // Adiciona o hEvent no array (array of THandle) de eventos...
    // Vou precisar disso depois pra chamar a WaitForMultipleObjectsEx
    // Passando o array de eventos como par�metro pra ele saber
    // poir quais eventos ele precisa esperar
    WaitArray[x] := Array_CompRoutineRequest.CompletionRoutineRequest[x].vOverlapped.hEvent;

    // Chamando a ReadFileEx que ir� fazer a leitura
    // Detalhes importantes...
    // 1 - O offset e o evento (que precisa ser sinalizado) est� definido na estrutura Overlapped
    // 2 - @CompletionRoutine � o nome da rotina que ser� chamada quando o evento for sinalizado
    ReadWorked := ReadFileEx(FileHandle,
                             Array_CompRoutineRequest.CompletionRoutineRequest[x].DataFileBufferPointer[x],
                             nNumberOfBytesToRead,
                             @Array_CompRoutineRequest.CompletionRoutineRequest[x].vOverlapped,
                             Array_CompRoutineRequest.CompletionRoutineRequest[x].CompletionRoutine);

    // Verificando se o resultado do ReadFileEx foi ok...
    // Se ele retornar True/0, deu certo... se retornar False/1 deu erro,
    // no caso de erro, a GetLastError() ir� informar qual erro...
    // Se o "erro" for ERROR_IO_PENDING segue a vida, isso significa que
    // o async I/O est� pendente..."The GetLastError code ERROR_IO_PENDING is not a failure;
    // it designates the read operation is pending completion asynchronously."
    if ReadWorked = False then
      ReadWorked := GetLastError() = ERROR_IO_PENDING;
    if ReadWorked = False then
      raise Exception.Create('Deu ruim na chamada da ReadFileEx... GetLastError() = ' + IntToStr(GetLastError()));
  end;


  // Enquanto I/Os est�o rodando posso usar a CPU pra alguma outra coisa...

  // Fingindo que estou fazendo algo e consumindo a CPU...
  Sleep(100);


  // I/Os criados e na teoria j� rodando... pra eu saber que terminaram e qual o status
  // tenho algumas op��es... Vamos analisar algumas...


  // Op��o 1
  // Posso chamar a WaitForSingleObject pra ficar esperando
  // que algum evento seja sinalizado...
  // Nesse caso, posso rodar a WaitForSingleObject(<hEvent>) utilizando
  // o evento criado e associado a estrutura overlapped.hEvent (lembra dele? veja no c�digo acima)
  
  // No SQL a opera��o de I/O vai ser "agrupada" em uma estrutura chamada
  // IoCompRequest(SOS_IOCompRequest) e adicionada(SOS_Scheduler::AddIOCompletionRequest) a uma fila de I/Os no
  // scheduler da thread que est� disparando o I/O...
  // Cada scheduler tem uma "Scheduler I/O queue", e a cada Switch (SOS_Scheduler::Switch)
  // a thread fazendo o Switch executa uma fun��o chamada CheckIOCompletions que
  // varre os itens da "Scheduler I/O queue" (m_IOList),
  // para cada I/O da fila, a HasOverlappedIoCompleted ser� executada
  // pra ver se os IO terminou...se sim, ent�o chama a GetOverlappedResult pra validar
  // o resultado dos bytes retornados pelo I/O, e depois chama a
  // sqlmin!BPool::ReadCompletionRoutine ou WriteCompletionRoutine (fun��o do CallBack, completion routine) pra
  // finalizar o I/O, acordar a thread que inicialmente disparou o I/O e est� esperando
  // e remover o I/O da "Scheduler I/O queue"...

  // Veja o que escrevi acima acontecendo nas stacks abaixo...

  // Thread 91 chamou um CreateDatabase (sqllang!CStmtCreateDB) que
  // chamou um sqlmin!AsynchronousDiskPool que ir� gerar os writes nos arquivos
  // utilizando v�rias threads
  {
  Rodar o CREATE DATABASE... windbg vai parar no sqlmin!FCB::SyncWrite

  Breakpoint 0 hit
  sqlmin!FCB::SyncWrite:
  00007fff`b4c0ac80 fff5            push    rbp
  0:111> k
   # Child-SP          RetAddr           Call Site
  00 00000064`2e6faa18 00007fff`b4c0b92d sqlmin!FCB::SyncWrite
  01 00000064`2e6faa20 00007fff`b4c0d67d sqlmin!FCB::PageWriteInternal+0x5d
  02 00000064`2e6fbaa0 00007fff`b4c0cd1d sqlmin!InitPFSPages+0xbe8
  03 00000064`2e6fbea0 00007fff`b5c9ea79 sqlmin!InitDBAllocPages+0x9d
  04 00000064`2e6fbf80 00007fff`b5bb9718 sqlmin!FileMgr::CreateNewFile+0x759
  05 00000064`2e6fcc00 00007fff`b5bbb216 sqlmin!AsynchronousDiskAction::ExecuteDeferredAction+0x94
  06 00000064`2e6fcca0 00007fff`b4ba20f3 sqlmin!AsynchronousDiskWorker::ThreadRoutine+0x106
  07 00000064`2e6fcd60 00007fff`dbfd9b33 sqlmin!SubprocEntrypoint+0xd25
  08 00000064`2e6fede0 00007fff`dbfda48d sqldk!SOS_Task::Param::Execute+0x232
  09 00000064`2e6ff3e0 00007fff`dbfda295 sqldk!SOS_Scheduler::RunTask+0xb5
  0a 00000064`2e6ff450 00007fff`dbff7020 sqldk!SOS_Scheduler::ProcessTasks+0x39d
  0b 00000064`2e6ff570 00007fff`dbff7b2b sqldk!SchedulerManager::WorkerEntryPoint+0x2a1
  0c 00000064`2e6ff640 00007fff`dbff7931 sqldk!SystemThreadDispatcher::ProcessWorker+0x402
  0d 00000064`2e6ff940 00007ff8`3f9b7bd4 sqldk!SchedulerManager::ThreadEntryPoint+0x3d8
  0e 00000064`2e6ffa30 00007ff8`4144ce51 KERNEL32!BaseThreadInitThunk+0x14
  0f 00000064`2e6ffa60 00000000`00000000 ntdll!RtlUserThreadStart+0x21


  !uniqstack vai retornar a stack de todas as threads...
  repare a thread 96 gerou comando de CREATE DATABASE (sqllang!CStmtCreateDB)
  e tem outras 3 threads (threads 111, 126 e 131) fazendo as I/Os pra escrever os arquivos...
  
  . 96  Id: 3cd8.278c Suspend: 1 Teb: 00000064`23568000 Unfrozen
        Start: sqldk!SchedulerManager::ThreadEntryPoint (00007fff`dbff76f0)
        Priority: 0  Priority class: 32  Affinity: fff
   # Child-SP          RetAddr           Call Site
  00 00000064`324fa8d8 00007ff8`3e3a8b03 ntdll!NtWaitForSingleObject+0x14
  01 00000064`324fa8e0 00007fff`dbfd1ae2 KERNELBASE!WaitForSingleObjectEx+0x93
  02 00000064`324fa980 00007fff`dbfd21ba sqldk!SOS_Scheduler::SwitchContext+0x745
  03 00000064`324face0 00007fff`dbfd3804 sqldk!SOS_Scheduler::SuspendNonPreemptive+0xe3
  04 00000064`324fad50 00007fff`b4c6cf5f sqldk!WaitableBase::Wait+0x16a
  05 00000064`324fadd0 00007fff`b4c78b29 sqlmin!AsynchronousDiskPool::WaitUntilDoneOrTimeout+0x10c
  06 00000064`324faf00 00007fff`b5beccb8 sqlmin!AsyncWorkerPool::DoWork+0x9
  07 00000064`324faf30 00007fff`b313897e sqlmin!DBMgr::CreateAndFormatFiles+0x3c8
  08 00000064`324fb330 00007fff`b3139209 sqllang!CStmtCreateDB::CreateLocalDatabaseFragment+0x8fe
  09 00000064`324fbbe0 00007fff`b313de6a sqllang!DBDDLAgent::CreateDatabase+0x169
  0a 00000064`324fbcf0 00007fff`b2547488 sqllang!CStmtCreateDB::XretExecute+0x130a
  0b 00000064`324fc8c0 00007fff`b2546ec8 sqllang!CMsqlExecContext::ExecuteStmts<1,1>+0x8f8
  0c 00000064`324fd460 00007fff`b2546513 sqllang!CMsqlExecContext::FExecute+0x946
  0d 00000064`324fe440 00007fff`b255031d sqllang!CSQLSource::Execute+0xb9c
  0e 00000064`324fe740 00007fff`b2531a55 sqllang!process_request+0xcdd
  0f 00000064`324fee40 00007fff`b2531833 sqllang!process_commands_internal+0x4b7
  10 00000064`324fef70 00007fff`dbfd9b33 sqllang!process_messages+0x1f3
  11 00000064`324ff150 00007fff`dbfda48d sqldk!SOS_Task::Param::Execute+0x232
  12 00000064`324ff750 00007fff`dbfda295 sqldk!SOS_Scheduler::RunTask+0xb5
  13 00000064`324ff7c0 00007fff`dbff7020 sqldk!SOS_Scheduler::ProcessTasks+0x39d
  14 00000064`324ff8e0 00007fff`dbff7b2b sqldk!SchedulerManager::WorkerEntryPoint+0x2a1
  15 00000064`324ff9b0 00007fff`dbff7931 sqldk!SystemThreadDispatcher::ProcessWorker+0x402
  16 00000064`324ffcb0 00007ff8`3f9b7bd4 sqldk!SchedulerManager::ThreadEntryPoint+0x3d8
  17 00000064`324ffda0 00007ff8`4144ce51 KERNEL32!BaseThreadInitThunk+0x14
  18 00000064`324ffdd0 00000000`00000000 ntdll!RtlUserThreadStart+0x21

  .111  Id: 3cd8.2bf8 Suspend: 1 Teb: 00000064`234a6000 Unfrozen
        Start: sqldk!SchedulerManager::ThreadEntryPoint (00007fff`dbff76f0)
        Priority: 0  Priority class: 32  Affinity: fff
   # Child-SP          RetAddr           Call Site
  00 00000064`2e6faa18 00007fff`b4c0b92d sqlmin!FCB::SyncWrite
  01 00000064`2e6faa20 00007fff`b4c0d67d sqlmin!FCB::PageWriteInternal+0x5d
  02 00000064`2e6fbaa0 00007fff`b4c0cd1d sqlmin!InitPFSPages+0xbe8
  03 00000064`2e6fbea0 00007fff`b5c9ea79 sqlmin!InitDBAllocPages+0x9d
  04 00000064`2e6fbf80 00007fff`b5bb9718 sqlmin!FileMgr::CreateNewFile+0x759
  05 00000064`2e6fcc00 00007fff`b5bbb216 sqlmin!AsynchronousDiskAction::ExecuteDeferredAction+0x94
  06 00000064`2e6fcca0 00007fff`b4ba20f3 sqlmin!AsynchronousDiskWorker::ThreadRoutine+0x106
  07 00000064`2e6fcd60 00007fff`dbfd9b33 sqlmin!SubprocEntrypoint+0xd25
  08 00000064`2e6fede0 00007fff`dbfda48d sqldk!SOS_Task::Param::Execute+0x232
  09 00000064`2e6ff3e0 00007fff`dbfda295 sqldk!SOS_Scheduler::RunTask+0xb5
  0a 00000064`2e6ff450 00007fff`dbff7020 sqldk!SOS_Scheduler::ProcessTasks+0x39d
  0b 00000064`2e6ff570 00007fff`dbff7b2b sqldk!SchedulerManager::WorkerEntryPoint+0x2a1
  0c 00000064`2e6ff640 00007fff`dbff7931 sqldk!SystemThreadDispatcher::ProcessWorker+0x402
  0d 00000064`2e6ff940 00007ff8`3f9b7bd4 sqldk!SchedulerManager::ThreadEntryPoint+0x3d8
  0e 00000064`2e6ffa30 00007ff8`4144ce51 KERNEL32!BaseThreadInitThunk+0x14
  0f 00000064`2e6ffa60 00000000`00000000 ntdll!RtlUserThreadStart+0x21

  .126  Id: 3cd8.5920 Suspend: 1 Teb: 00000064`234ea000 Unfrozen
        Start: sqldk!SchedulerManager::ThreadEntryPoint (00007fff`dbff76f0)
        Priority: 0  Priority class: 32  Affinity: fff
   # Child-SP          RetAddr           Call Site
  00 00000064`2e4f86d8 00007ff8`3e394544 ntdll!NtCreateFile+0x14
  01 00000064`2e4f86e0 00007ff8`3e394236 KERNELBASE!CreateFileInternal+0x2f4
  02 00000064`2e4f8850 00007fff`b5e45a4f KERNELBASE!CreateFileW+0x66
  03 00000064`2e4f88b0 00007fff`b5e40a7b sqlmin!Win32FileSystemHandler::CreateFileW+0x18f
  04 00000064`2e4f8bd0 00007fff`b5c31c0f sqlmin!DBCreateFileW+0x7b
  05 00000064`2e4f8c30 00007fff`b5c322b6 sqlmin!CreateFileInternalEx+0x11f
  06 00000064`2e4f9cb0 00007fff`b5c9e5ce sqlmin!FCB::CreatePhysicalFile+0x426
  07 00000064`2e4fbdb0 00007fff`b5bb9718 sqlmin!FileMgr::CreateNewFile+0x2ae
  08 00000064`2e4fca30 00007fff`b5bbb216 sqlmin!AsynchronousDiskAction::ExecuteDeferredAction+0x94
  09 00000064`2e4fcad0 00007fff`b4ba20f3 sqlmin!AsynchronousDiskWorker::ThreadRoutine+0x106
  0a 00000064`2e4fcb90 00007fff`dbfd9b33 sqlmin!SubprocEntrypoint+0xd25
  0b 00000064`2e4fec10 00007fff`dbfda48d sqldk!SOS_Task::Param::Execute+0x232
  0c 00000064`2e4ff210 00007fff`dbfda295 sqldk!SOS_Scheduler::RunTask+0xb5
  0d 00000064`2e4ff280 00007fff`dbff7020 sqldk!SOS_Scheduler::ProcessTasks+0x39d
  0e 00000064`2e4ff3a0 00007fff`dbff7b2b sqldk!SchedulerManager::WorkerEntryPoint+0x2a1
  0f 00000064`2e4ff470 00007fff`dbff7931 sqldk!SystemThreadDispatcher::ProcessWorker+0x402
  10 00000064`2e4ff770 00007ff8`3f9b7bd4 sqldk!SchedulerManager::ThreadEntryPoint+0x3d8
  11 00000064`2e4ff860 00007ff8`4144ce51 KERNEL32!BaseThreadInitThunk+0x14
  12 00000064`2e4ff890 00000000`00000000 ntdll!RtlUserThreadStart+0x21

  .131  Id: 3cd8.1cb8 Suspend: 1 Teb: 00000064`234f4000 Unfrozen
        Start: sqldk!SchedulerManager::ThreadEntryPoint (00007fff`dbff76f0)
        Priority: 0  Priority class: 32  Affinity: fff
   # Child-SP          RetAddr           Call Site
  00 00000064`2f4f6be8 00007ff8`3e3d68f2 ntdll!NtSetInformationFile+0x14
  01 00000064`2f4f6bf0 00007fff`b4c0bc20 KERNELBASE!SetEndOfFile+0x92
  02 00000064`2f4f6c40 00007fff`b4c0bb67 sqlmin!DiskChangeFileSize+0x70
  03 00000064`2f4f6ce0 00007fff`b5c3261a sqlmin!FCB::ChangeFileSize+0x3bc
  04 00000064`2f4f9fe0 00007fff`b5c9e5ce sqlmin!FCB::CreatePhysicalFile+0x78a
  05 00000064`2f4fc0e0 00007fff`b5bb9718 sqlmin!FileMgr::CreateNewFile+0x2ae
  06 00000064`2f4fcd60 00007fff`b5bbb216 sqlmin!AsynchronousDiskAction::ExecuteDeferredAction+0x94
  07 00000064`2f4fce00 00007fff`b4ba20f3 sqlmin!AsynchronousDiskWorker::ThreadRoutine+0x106
  08 00000064`2f4fcec0 00007fff`dbfd9b33 sqlmin!SubprocEntrypoint+0xd25
  09 00000064`2f4fef40 00007fff`dbfda48d sqldk!SOS_Task::Param::Execute+0x232
  0a 00000064`2f4ff540 00007fff`dbfda295 sqldk!SOS_Scheduler::RunTask+0xb5
  0b 00000064`2f4ff5b0 00007fff`dbff7020 sqldk!SOS_Scheduler::ProcessTasks+0x39d
  0c 00000064`2f4ff6d0 00007fff`dbff7b2b sqldk!SchedulerManager::WorkerEntryPoint+0x2a1
  0d 00000064`2f4ff7a0 00007fff`dbff7931 sqldk!SystemThreadDispatcher::ProcessWorker+0x402
  0e 00000064`2f4ffaa0 00007ff8`3f9b7bd4 sqldk!SchedulerManager::ThreadEntryPoint+0x3d8
  0f 00000064`2f4ffb90 00007ff8`4144ce51 KERNEL32!BaseThreadInitThunk+0x14
  10 00000064`2f4ffbc0 00000000`00000000 ntdll!RtlUserThreadStart+0x21

  Outra thread (36) qualquer que estava la vacilando esta lendo o "Scheduler I/O queue"
  e verificando se o I/O terminou...
  Chamou CheckForIOCompletion -> GetOverlappedResult -> Depois disso vai chamar a CompletionRoutine que ir�
  "acordar"/sinalizar a thread que disparou o I/O... e est� esperando em NtSignalAndWaitForSingleObject

  0:036> k
   # Child-SP          RetAddr           Call Site
  00 00000064`28dfd8b8 00007fff`b4b2f218 KERNELBASE!GetOverlappedResult
  01 00000064`28dfd8c0 00007fff`dbfee0ec sqlmin!DBGetOverlappedResult+0x44
  02 00000064`28dfd900 00007fff`dbfd1cb1 sqldk!IOQueue::CheckForIOCompletion+0x2ce
  03 00000064`28dfdaa0 00007fff`dbfd21ba sqldk!SOS_Scheduler::SwitchContext+0x1e5
  04 00000064`28dfde00 00007fff`dbfebfdc sqldk!SOS_Scheduler::SuspendNonPreemptive+0xe3
  05 00000064`28dfde70 00007fff`dbfebedc sqldk!SOS_Task::Sleep+0x131
  06 00000064`28dfded0 00007fff`b4b956ea sqldk!Worker::OSYieldNoAbort+0x2c
  07 00000064`28dfdf00 00007fff`dbfd37e8 sqlmin!EventInternal<SuspendQueueSLock>::ExecutePreWaitSteps+0x8a
  08 00000064`28dfdf60 00007fff`b4af9e22 sqldk!WaitableBase::Wait+0x14e
  09 00000064`28dfdfe0 00007fff`b5bbed6c sqlmin!BPool::LazyWriter+0x826
  0a 00000064`28dfedb0 00007fff`dbfd9b33 sqlmin!lazywriter+0x24c
  0b 00000064`28dff230 00007fff`dbfda48d sqldk!SOS_Task::Param::Execute+0x232
  0c 00000064`28dff830 00007fff`dbfda295 sqldk!SOS_Scheduler::RunTask+0xb5
  0d 00000064`28dff8a0 00007fff`dbff7020 sqldk!SOS_Scheduler::ProcessTasks+0x39d
  0e 00000064`28dff9c0 00007fff`dbff7b2b sqldk!SchedulerManager::WorkerEntryPoint+0x2a1
  0f 00000064`28dffa90 00007fff`dbff7931 sqldk!SystemThreadDispatcher::ProcessWorker+0x402
  10 00000064`28dffd90 00007ff8`3f9b7bd4 sqldk!SchedulerManager::ThreadEntryPoint+0x3d8
  11 00000064`28dffe80 00007ff8`4144ce51 KERNEL32!BaseThreadInitThunk+0x14
  12 00000064`28dffeb0 00000000`00000000 ntdll!RtlUserThreadStart+0x21
  ...

  Nessa altura a thread gerou o I/O... est� parada em NtSignalAndWaitForSingleObject

    .126  Id: 3cd8.5920 Suspend: 1 Teb: 00000064`234ea000 Unfrozen
        Start: sqldk!SchedulerManager::ThreadEntryPoint (00007fff`dbff76f0)
        Priority: 0  Priority class: 32  Affinity: fff
   # Child-SP          RetAddr           Call Site
  00 00000064`2e4f86e8 00007ff8`3e467bef ntdll!NtSignalAndWaitForSingleObject+0x14
  01 00000064`2e4f86f0 00007fff`dbfdb685 KERNELBASE!SignalObjectAndWait+0xcf
  02 00000064`2e4f87a0 00007fff`dbfdb590 sqldk!SOS_Scheduler::SwitchToThreadWorker+0x136
  03 00000064`2e4f8a70 00007fff`dbfd21ba sqldk!SOS_Scheduler::Switch+0x8e
  04 00000064`2e4f8ab0 00007fff`dbfd3804 sqldk!SOS_Scheduler::SuspendNonPreemptive+0xe3
  05 00000064`2e4f8b20 00007fff`b4c0adb0 sqldk!WaitableBase::Wait+0x16a
  06 00000064`2e4f8ba0 00007fff`b5f7e63c sqlmin!FCB::SyncWrite+0x13f
  07 00000064`2e4f8cc0 00007fff`b5f7e4ab sqlmin!SQLServerLogMgr::FormatVirtualLogFile+0x15c
  08 00000064`2e4fbd50 00007fff`b5c9ea39 sqlmin!SQLServerLogMgr::FormatLogFile+0x22b
  09 00000064`2e4fbdb0 00007fff`b5bb9718 sqlmin!FileMgr::CreateNewFile+0x719
  0a 00000064`2e4fca30 00007fff`b5bbb216 sqlmin!AsynchronousDiskAction::ExecuteDeferredAction+0x94
  0b 00000064`2e4fcad0 00007fff`b4ba20f3 sqlmin!AsynchronousDiskWorker::ThreadRoutine+0x106
  0c 00000064`2e4fcb90 00007fff`dbfd9b33 sqlmin!SubprocEntrypoint+0xd25
  0d 00000064`2e4fec10 00007fff`dbfda48d sqldk!SOS_Task::Param::Execute+0x232
  0e 00000064`2e4ff210 00007fff`dbfda295 sqldk!SOS_Scheduler::RunTask+0xb5
  0f 00000064`2e4ff280 00007fff`dbff7020 sqldk!SOS_Scheduler::ProcessTasks+0x39d
  10 00000064`2e4ff3a0 00007fff`dbff7b2b sqldk!SchedulerManager::WorkerEntryPoint+0x2a1
  11 00000064`2e4ff470 00007fff`dbff7931 sqldk!SystemThreadDispatcher::ProcessWorker+0x402
  12 00000064`2e4ff770 00007ff8`3f9b7bd4 sqldk!SchedulerManager::ThreadEntryPoint+0x3d8
  13 00000064`2e4ff860 00007ff8`4144ce51 KERNEL32!BaseThreadInitThunk+0x14
  14 00000064`2e4ff890 00000000`00000000 ntdll!RtlUserThreadStart+0x21
  }

  // Op��o 2
  // Posso ficar esperando os eventos utilizados no I/O async (estrutura overlapped)
  // serem sinalizados via WaitForMultipleObjectsEx
  // Essa function tem um par�metro que indica por quanto tempo
  // esperar o I/O e quando ela terminar, ela j� chama a CompletionRoutine
  // especificada ao chamar o comando ReadFileEx...

  {
  // C�digo pra utilizar a op��o 2
  // Utilizando a WaitForMultipleObjectsEx para chamar a CompletionRoutine
  WaitForMultipleObjectsEx(nThreads, @WaitArray, True, INFINITE, True);

  Memo3.Lines.AddStrings(CompletionRoutineResultMemo.Lines);
  Memo3.Refresh;
  Application.ProcessMessages;

  while (CompletionRoutineTotalBytesTransfered > 0) do
  begin
    InitialPos := CompletionRoutineTotalBytesTransfered;
    CompletionRoutineResultMemo.Clear;
    Goto GotoScanFile;
  end;
  }

  // Op��o 3 (Essa � a op��o que estamos utilizando aqui...)
  // Posso chamar a HasOverlappedIoCompleted pra saber se o I/O terminou...
  // Se n�o terminou posso continuar usando CPU pra outra coisa...

  // C�digo pra utilizar a op��o 3 utilizando HasOverlappedIoCompleted pra saber se a
  // primeira(Array_CompRoutineRequest.CompletionRoutineRequest[<zero>].vOverlapped) requisic�o de I/O j� terminou...
  HasOverlappedIoCompletedResult := HasOverlappedIoCompleted(Array_CompRoutineRequest.CompletionRoutineRequest[0].vOverlapped);
  // Se HasOverlappedIoCompletedResult = false, ent�o I/O n�o terminou... posso usar CPU pra mais alguma coisa e
  // consultar novamente depois
  if HasOverlappedIoCompletedResult = false then
  begin
    // Fingindo que estou fazendo mais alguma coisa e consumindo CPU...
    Sleep(100);

    // Verificando novamente se o I/O terminou...
    HasOverlappedIoCompletedResult := HasOverlappedIoCompleted(Array_CompRoutineRequest.CompletionRoutineRequest[0].vOverlapped);
    if HasOverlappedIoCompletedResult = false then
    begin
      // Fingindo que estou fazendo mais alguma coisa e consumindo CPU...
     Sleep(100);
    end;
  end; 






  // Op��o 4
  // Posso chamar a GetOverlappedResult pra saber o resultado da leitura

  // C�digo pra utilizar a op��o 4
  // Utilizando GetOverlappedResult para pegar o resultado do I/O
  // Consulta o resultado, para cada thread criada
  for x := 0 to Pred(nThreads) do
  begin
    VarlpNumberOfBytesTransferred := 0;

    // Chamando a GetOverlappedResult especificando o
    // FileHandle lido...
    // Estrutura Overlapped que quero verificar o resultado
    // VarlpNumberOfBytesTransferred ir� receber o resultado de bytes lidos...
    // �ltimo parametro bWait = true, significa que quero esperar o I/O terminar...
    GetOverlappedResult1 := GetOverlappedResult(FileHandle, Array_CompRoutineRequest.CompletionRoutineRequest[x].vOverlapped, VarlpNumberOfBytesTransferred, True);

    // Se GetOverlappedResult retornou que o I/O N�O terminou com sucesso
    if GetOverlappedResult1 = False then
    begin
      //ERROR_HANDLE_EOF = 38
      // Verifica se o erro � ERROR_HANDLE_EOF, se sim, significa que chegamos
      // no final o arquivo...
      if GetLastError() = ERROR_HANDLE_EOF then
        // Adiciona o no Memo pra eu saber que chegou no final do arquivo...
        Memo3.Lines.Add('ERROR_HANDLE_EOF')
      else
        // Se for algum outro erro adiciona no Memo pra eu saber
        Memo3.Lines.Add('Algum outro erro no resultado da GetOverlappedResult, GetLastError() = ' + IntToStr(GetLastError()));

      // Set CompletionRoutineTotalBytesTransfered para zero pra eu saber que n�o
      // preciso continuar a leitura...
      CompletionRoutineTotalBytesTransfered := 0;
      Break;
    end;
    
    // Se VarlpNumberOfBytesTransferred tiver algo... soma com o CompletionRoutineTotalBytesTransfered
    // pra eu saber quantos bytes j� foram lidos...
    // Se chegou no final do arquivo  CompletionRoutineTotalBytesTransfered e VarlpNumberOfBytesTransferred
    // estar�o zerados e soma vai ser zero...
    CompletionRoutineTotalBytesTransfered := CompletionRoutineTotalBytesTransfered + VarlpNumberOfBytesTransferred;

    // Se GetOverlappedResult preencheu VarlpNumberOfBytesTransferred com algo
    // L� os dados do Pchar Array DataFileBufferPointer e chama a Completion Routine
    // pra ler o que foi lido e fazer o cleanup...
    if VarlpNumberOfBytesTransferred > 0 then
    begin
      CompletionRoutine(GetLastError(), VarlpNumberOfBytesTransferred, Array_CompRoutineRequest.CompletionRoutineRequest[x].vOverlapped);
    end
    else
    begin
      // Se nenhum byte foi lido... zera CompletionRoutineTotalBytesTransfered
      // pra parar as leituras... se nada foi lido, provavelmente chegou no final do
      // arquivo...
      CompletionRoutineTotalBytesTransfered := 0;
      Break;
    end;
  end;

  // Exibe os dados do Memo populado na completion routine no memo do form1
  Memo3.Lines := CompletionRoutineResultMemo.Lines;

  // Enquanto CompletionRoutineTotalBytesTransfered n�o indicar
  // que nenhum byte foi lido continua gerando threads pra continuar leitura
  while (CompletionRoutineTotalBytesTransfered > 0) do
  begin
    InitialPos := CompletionRoutineTotalBytesTransfered;
    GOTO GotoScanFile;
  end;
end;

procedure TForm1.Cleanup;
begin
  CloseHandle(FileHandle);
  ZeroMemory(@Array_CompRoutineRequest, sizeof(Array_CompRoutineRequest));
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Memo3.Clear;
  InitFileAndSections();
  DoRead(0);
  Cleanup();
end;

end.
