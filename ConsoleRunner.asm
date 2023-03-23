format pe console
entry main

include "win32ax.inc"

macro return x {
    mov eax, x
    ret }

crlf equ 13,10

section ".code" code readable executable

main:
	
	invoke CreateFile,"c:\\Tmp\\kl\\data.txt",GENERIC_READ,NULL,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	mov [hInputFile],eax

    invoke GetFileSize,[hInputFile],NULL
    mov [dwFileSize],eax

    invoke LocalAlloc,LPTR,[dwFileSize]
   	mov [lpBuffer],eax

    invoke ReadFile,[hInputFile],[lpBuffer],[dwFileSize],dwBytesRead,NULL

    invoke CloseHandle,[hInputFile]
    invoke CreateFile,"c:\\Tmp\\kl\\new.txt",GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
    mov [hOutputFile],eax

    invoke WriteFile,[hOutputFile],[lpBuffer],[dwFileSize],dwBytesWritten,NULL

    invoke CloseHandle,[hOutputFile]

    invoke LocalFree,[lpBuffer]

	invoke SetConsoleCtrlHandler, CtrlHandler, TRUE
    .if ( eax )
        stdcall MyPrintString        	
		.while ( 1 )
	.endw

	.endif

    invoke ExitProcess,NULL


proc MyPrintString
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

        hInputFile      dd 0
        hOutputFile     dd 0
        dwFileSize      dd 0
        dwBytesRead     dd 0
        dwBytesWritten  dd 0
        lpBuffer        dd 0

section '.idata' import data readable

 library kernel32,'KERNEL32.DLL',\
         user32,'USER32.DLL',\
         msvcrt, "msvcrt.dll"

            import msvcrt,\
                printf, "printf"

 include 'api\kernel32.inc'
 include 'api\user32.inc'    
