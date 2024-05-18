unit XPCPU;

interface

type
  TCPUInstructionSet = (ciMMX, ciEMMX, ciSSE, ciSSE2, ci3DNow, ci3DNowExt);

  TXPCPU = class
  private
  class var
    FAlphaTable: array of LongWord;
    FMMXEnabled: Boolean;
    class procedure Initailize; static;
    class procedure Finalize; static;
  protected
    class procedure SetMMXEnabled(NewValue: Boolean); static;
  public
    class function HasInstructionSet(const InstructionSet: TCPUInstructionSet): Boolean;
    class function HasMMX: Boolean;       { CPU supports MMX instructions }
    class function HasEMMX: Boolean;      { CPU supports the Extended MMX (aka Integer SSE) instructions }
    class function Has3DNow: Boolean;     { CPU supports 3DNow! instructions }
    class function Has3DNowExt: Boolean;  { CPU supports 3DNow! Extended instructions }
    class function HasSSE: Boolean;       { CPU supports SSE instructions }
    class function HasSSE2: Boolean;      { CPU supports SSE2 instructions }
    class property MMXEnabled: Boolean read FMMXEnabled write SetMMXEnabled;
  end;

const
  CPUISChecks: array[TCPUInstructionSet] of Cardinal = (
    $800000,    // ciMMX
    $400000,    // ciEMMX
    $2000000,   // ciSSE
    $4000000,   // ciSSE2
    $80000000,  // ci3DNow
    $40000000   // ci3DNowExt
  );

var
  MMXBiasPtr, MMXAlphaPtr: Pointer;

procedure EMMS;

implementation

procedure EMMS;
begin
{$IFDEF WIN32}
  if TXPCPU.FMMXEnabled then
  asm
    emms;
  end;
{$ENDIF}
end;

function CPUID_Available: Boolean;
{$IFDEF WIN32}
asm
    mov       edx,False
    pushfd
    pop       eax
    mov       ecx,eax
    xor       eax,$00200000
    push      eax
    popfd
    pushfd
    pop       eax
    xor       ecx,eax
    jz        @exit
    mov       edx,True
  @exit:
    push      eax
    popfd
    mov       eax,edx
{$ELSE}
begin
  Result := False;
{$ENDIF}
end;

function CPU_Signature: Integer;
{$IFDEF WIN32}
asm
    push    ebx
    mov     eax,1
    dw      $A20F   // cpuid
    pop     ebx
{$ELSE}
begin
  Result := 0;
{$ENDIF}
end;

function CPU_Features: Integer;
{$IFDEF WIN32}
asm
    push    ebx
    mov     eax,1
    dw      $A20F   // cpuid
    pop     ebx
    mov     eax,edx
{$ELSE}
begin
  Result := 0;
{$ENDIF}
end;

function CPU_ExtensionsAvailable: Boolean;
{$IFDEF WIN32}
asm
    push    ebx
    mov     @Result,True
    mov     eax,$80000000
    dw      $A20F   // cpuid
    cmp     eax,$80000000
    jbe     @noextension
    jmp     @exit
  @noextension:
    mov     @Result,False
  @exit:
    pop     ebx
{$ELSE}
begin
  Result := False;
{$ENDIF}
end;

function CPU_ExtFeatures: Integer;
{$IFDEF WIN32}
asm
    push    ebx
    mov     eax,$80000001
    dw      $A20F   // cpuid
    pop     ebx
    mov     eax,edx
{$ELSE}
begin
  Result := 0;
{$ENDIF}
end;

{ TXPMMX }

class procedure TXPCPU.Initailize;
var
  n: Integer;
  l: Longword;
  lptr: ^Longword;
begin
  SetLength(FAlphaTable, 514);
{$IFDEF Win32}
  MMXAlphaPtr := Pointer(Integer(FAlphaTable) and $FFFFFFF8);
  if Integer(MMXAlphaPtr) < Integer(FAlphaTable) then
    MMXAlphaPtr := Pointer(Integer(MMXAlphaPtr) + 8);
{$ELSE}
  MMXAlphaPtr := Pointer(Int64(FAlphaTable) and $FFFFFFFFFFFFFFF8);
  if Int64(MMXAlphaPtr) < Int64(FAlphaTable) then
    MMXAlphaPtr := Pointer(Int64(MMXAlphaPtr) + 8);
{$ENDIF}
  lptr := MMXAlphaPtr;
  for n := 0 to 255 do
  begin
    l := n + (n shl 16);
    lptr^ := l;
    Inc(lptr);
    lptr^ := l;
    Inc(lptr);
  end;
{$IFDEF Win32}
  MMXBiasPtr := Pointer(Integer(MMXAlphaPtr) + $80 * 8);
{$ELSE}
  MMXBiasPtr := Pointer(Int64(MMXAlphaPtr) + $80 * 8);
{$ENDIF}
  FMMXEnabled := HasMMX;
end;

class procedure TXPCPU.Finalize;
begin
  FAlphaTable := nil;
end;

class function TXPCPU.HasMMX: Boolean;
begin
  Result := HasInstructionSet(ciMMX);
end;

class function TXPCPU.HasEMMX: Boolean;
begin
  Result := HasInstructionSet(ciEMMX);
end;

class function TXPCPU.HasInstructionSet(
  const InstructionSet: TCPUInstructionSet): Boolean;
begin
  Result := False;
  if not CPUID_Available then Exit;               // no CPUID available
  if CPU_Signature shr 8 and $0F < 5 then Exit;   // not a Pentium class

  case InstructionSet of
    ci3DNow, ci3DNowExt:
      if not CPU_ExtensionsAvailable
        or (CPU_ExtFeatures and CPUISChecks[InstructionSet] = 0)
      then Exit;
    ciEMMX:
    begin
      // check for SSE, necessary for Intel CPUs because they don't implement the
      // extended info
      if (CPU_Features and CPUISChecks[ciSSE] = 0)
        and (not CPU_ExtensionsAvailable or (CPU_ExtFeatures and CPUISChecks[ciEMMX] = 0))
      then Exit;
    end;
  else
    if CPU_Features and CPUISChecks[InstructionSet] = 0 then
      Exit; // return -> instruction set not supported
  end;
  Result := True;
end;

class function TXPCPU.HasSSE: Boolean;
begin
  Result := HasInstructionSet(ciSSE);
end;

class function TXPCPU.HasSSE2: Boolean;
begin
  Result := HasInstructionSet(ciSSE2);
end;

class procedure TXPCPU.SetMMXEnabled(NewValue: Boolean);
begin
  FMMXEnabled := NewValue and HasMMX;
end;

class function TXPCPU.Has3DNow: Boolean;
begin
  Result := HasInstructionSet(ci3DNow);
end;

class function TXPCPU.Has3DNowExt: Boolean;
begin
  Result := HasInstructionSet(ci3DNowExt);
end;

initialization
  TXPCPU.Initailize;

finalization
  TXPCPU.Finalize;

end.
