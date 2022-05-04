;===============================================================================
;       global data
;       --------------------------------
;       idata
;       --------------------------------
macro idata arg {
 __IData equ __IData,
 macro __IDataBlock
  arg }
;       --------------------------------
;       udata
;       --------------------------------
macro udata arg {
 __UData equ __UData,
 macro __UDataBlock
  arg }
;       --------------------------------
;       IncludeIData
;       --------------------------------
macro IncludeIData {
 macro __IData dummy,[n]
 \{
  \forward
   __IDataBlock
   purge __IDataBlock
 \}
 match I, __IData \{ I \}
 purge __IData }
;       --------------------------------
;       IncludeUData
;       --------------------------------
macro IncludeUData {
 macro __UData dummy,[n]
 \{
  \common
   \local ..begin, ..size
   ..begin = $
   virtual at $
  \forward
   __UDataBlock
   purge __UDataBlock
  \common
   ..size = $ - ..begin
   end virtual
   rb ..size
 \}
 match U, __UData \{ U \}
 purge __UData }
;       --------------------------------
;       IncludeAllData
;       --------------------------------
macro IncludeAllData {
 IncludeIData
 IncludeUData }
;       --------------------------------
;       ...
;       --------------------------------
idata { }
udata { }

;===============================================================================
;       imports
;       --------------------------------
;       import_#lib
;       --------------------------------
macro import lib, [functions] {
 common macro import_#lib \{ import lib, functions \} }
;       --------------------------------
;       includes
;       --------------------------------
include '%fasminc%/apia/kernel32.inc'
include '%fasminc%/apia/user32.inc'
include '%fasminc%/apia/gdi32.inc'
include '%fasminc%/apia/advapi32.inc'
include '%fasminc%/apia/comctl32.inc'
include '%fasminc%/apia/comdlg32.inc'
include '%fasminc%/apia/shell32.inc'
include '%fasminc%/apia/wsock32.inc'
include 'msvcrt.inc'
;       --------------------------------
purge import
;       --------------------------------
;       IncludeAllImports
;       --------------------------------
macro IncludeAllImports {
 data import
  library kernel32,'KERNEL32.DLL',\
	  user32,'USER32.DLL',\
	  gdi32,'GDI32.DLL',\
	  advapi32,'ADVAPI32.DLL',\
	  comctl32,'COMCTL32.DLL',\
	  comdlg32,'COMDLG32.DLL',\
	  shell32,'SHELL32.DLL',\
	  wsock32,'WSOCK32.DLL',\
	  msvcrt,'MSVCRT.DLL'

  import_kernel32
  import_user32
  import_gdi32
  import_advapi32
  import_comctl32
  import_comdlg32
  import_shell32
  import_wsock32
  import_msvcrt
 end data }

;===============================================================================
;       string array definition
struc string_array [string] {
 forward
  local __label
  __label db string, 0
 common
  local __counter
  label . dword
  __counter = 0
 forward
  dd __label
  __counter = __counter + 1
 common
  .item_count = __counter }

;===============================================================================
;       emulates usage of double anonymous labels
macro @@@ colon
{ @@b equ @@f 
  @@b: 
  local ..new 
  @@f equ ..new }