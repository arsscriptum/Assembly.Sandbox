format pe console
entry main

include "win32ax.inc"

macro return x {
    mov eax, x
    ret }

crlf equ 13,10

section ".code" code readable executable

main:
    stdcall Introduction
    stdcall [GetSystemTime], Time
    movsx eax, [Time.wHour]
    movsx ebx, [Time.wMinute]
    movsx edi, [Time.wSecond]
    cinvoke wsprintf,_buffer_time,_format_time,eax,ebx,edi
  
    stdcall WriteToFile, addr _buffer_time

    ;invoke SetConsoleCtrlHandler, CtrlHandler, TRUE
    ;.if ( eax )         
    ;    .while ( 1 )
    ;.endw

    ;.endif

    invoke ExitProcess,NULL



;========================================================================
; WriteToFile
;========================================================================

proc WriteToFile uses esi, wText
    locals
        dwBytesWritten      rd 1
        hFile               rd 1
    endl

    invoke CreateFile,"c:\\Tmp\\kl\\new.txt",GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
    .if eax <> INVALID_HANDLE_VALUE
        mov [hFile], eax
        invoke lstrlenW, [wText]
        imul eax, 2
        invoke WriteFile, [hFile], [wText], eax, addr dwBytesWritten, NULL
        .if eax = 1
            invoke CloseHandle, [hFile]
            xor eax, eax
            inc eax
            ret
        .endif
    .endif

    xor eax, eax
    ret
endp

   
;========================================================================
; Introduction
;========================================================================
proc Introduction
    cinvoke printf, <crlf,"=========================",crlf>
    cinvoke printf, <"  Simple Console Runner  ",crlf>
    cinvoke printf, <"=========================",crlf>
    cinvoke printf, <" use Ctrl+C or Ctrl+Break",crlf>
endp 


proc CtrlHandler uses ecx edx, fdwCtrlType:DWORD

            mov eax, [fdwCtrlType]

            ; Handle the CTRL-C signal.
            .if ( eax = CTRL_C_EVENT )
                cinvoke printf, <" .">
                return TRUE

            ; CTRL-CLOSE: confirm that the user wants to exit.
            .elseif ( eax = CTRL_CLOSE_EVENT )
                cinvoke printf, <"rcv event  ">
                return TRUE 
            .elseif ( eax = CTRL_BREAK_EVENT )
                cinvoke printf, <"BREAK",crlf>
                return FALSE
            .else
                return FALSE

            .endif

                .default:
            return FALSE
endp



section '.data' data readable writable

      _format_date     db '%02d/%02d/%4d',0
      _buffer_date     rb 11                                        ; 11 bytes reserved (xx/xx/xxxx0)
                       db 0

      _format_time     db '%02d:%02d:%02d',0
      _format_time_str     db '%s',0
      _buffer_time     rb 9                                         ; 9 bytes reserved (xx:xx:xx0)
                       db 0
        hOutputFile     dd 0
        dwFileSize      dd 0
        dwBytesRead     dd 0
        dwBytesWritten  dd 0
        lpBuffer        dd 0
        lpSystemTime     SYSTEMTIME  
        buffer_format    db '%s/%s/%s',0
        output           rb 11                                        ; 11 bytes reserved (xx/xx/xxxx0)
        Time   SYSTEMTIME
        dday             db '22',0
        dmon             db '09',0
        dyear            db '1967',0
Msg:
.Date_S db '00.00.0000'
db '-'
.Time_S db '00:00:00'
Msg._size = $ - Msg
Msg.Len dd 0

section '.idata' import data readable

 library kernel32,'KERNEL32.DLL',\
         user32,'USER32.DLL',\
         msvcrt, "msvcrt.dll"

    import msvcrt,\
    printf, "printf"


 include 'api\kernel32.inc'
 include 'api\user32.inc'    
