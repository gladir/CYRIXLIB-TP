{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2023
  @website(https://www.gladir.com/CODER/CYRIXLIB-TP)
  @abstract(Target: Turbo Pascal 7)
}

Unit CYRIXLIB;

INTERFACE

Type
 Cyrix6x86Config=Record
  FastFrameBuffer:Boolean;
  WriteBackCache:Boolean;
  WriteAllocate:Boolean;
  CPUID:Boolean;
  SuspendonHALT:Boolean;
  CachedDirectoryTableEntry:Boolean;
  NegateLock:Boolean;
  DataForwarding:Boolean;
  FastLoop:Boolean;
 End;

Procedure GetCyrix6x86Config(Var Q:Cyrix6x86Config);
Procedure SetCyrix6x86Config(Var Q:Cyrix6x86Config);
Procedure SetCPUIDFromCyrix(X:Boolean);

IMPLEMENTATION

Procedure GetCyrix6x86Config(Var Q:Cyrix6x86Config);Assembler;ASM
 {$IFDEF FLAT386}
  LEA EDI,DWord Ptr Q
  MOV AL,0C1h
  OUT 22h,AL
  IN  AL,23h
  SHR AL,4
  AND AL,1
  MOV [EDI].Cyrix6x86Config.NegateLock,AL
  MOV AL,0C2h
  OUT 22h,AL
  IN  AL,23h
  SHR AL,1
  MOV BL,AL
  AND BL,1
  MOV [EDI].Cyrix6x86Config.WriteBackCache,BL
  SHR AL,2
  AND AL,1
  MOV [EDI].Cyrix6x86Config.SuspendOnHALT,AL
  MOV AL,0C3h { CCR3 }
  OUT 22h,AL
  IN  AL,23h
  SHR AL,2
  AND AL,1
  MOV [EDI].Cyrix6x86Config.FastFrameBuffer,AL
  MOV AL,0E8h { CCR4 }
  OUT 22h,AL
  IN  AL,23h
  MOV BL,AL
  ROL BL,1
  AND BL,1
  MOV [EDI].Cyrix6x86Config.CPUID,BL
  SHR AL,4
  AND AL,1
  MOV [EDI].Cyrix6x86Config.CachedDirectoryTableEntry,AL
  MOV AL,0E9h { CCR5 }
  OUT 22h,AL
  IN  AL,23h
  MOV BL,AL
  AND AL,1
  MOV [EDI].Cyrix6x86Config.WriteAllocate,AL
  SHR BL,1
  AND BL,1
  XOR BL,1
  MOV [EDI].Cyrix6x86Config.FastLoop,AL
 {$ELSE}
  LES DI,Q
  MOV AL,0C1h
  OUT 22h,AL
  IN  AL,23h
  {$IFOPT G+}
   SHR AL,4
  {$ELSE}
   SHR AL,1
   SHR AL,1
   SHR AL,1
   SHR AL,1
  {$ENDIF}
  AND AL,1
  MOV ES:[DI].Cyrix6x86Config.NegateLock,AL
  MOV AL,0C2h
  OUT 22h,AL
  IN  AL,23h
  SHR AL,1
  MOV BL,AL
  AND BL,1
  MOV ES:[DI].Cyrix6x86Config.WriteBackCache,BL
  {$IFOPT G+}
   SHR AL,2
  {$ELSE}
   SHR AL,1
   SHR AL,1
  {$ENDIF}
  AND AL,1
  MOV ES:[DI].Cyrix6x86Config.SuspendOnHALT,AL
  MOV AL,0C3h { CCR3 }
  OUT 22h,AL
  IN  AL,23h
  {$IFOPT G+}
   SHR AL,2
  {$ELSE}
   SHR AL,1
   SHR AL,1
  {$ENDIF}
  AND AL,1
  MOV ES:[DI].Cyrix6x86Config.FastFrameBuffer,AL
  MOV AL,0E8h { CCR4 }
  OUT 22h,AL
  IN  AL,23h
  MOV BL,AL
  ROL BL,1
  AND BL,1
  MOV ES:[DI].Cyrix6x86Config.CPUID,BL
  {$IFOPT G+}
   SHR AL,4
  {$ELSE}
   SHR AL,1
   SHR AL,1
   SHR AL,1
   SHR AL,1
  {$ENDIF}
  AND AL,1
  MOV ES:[DI].Cyrix6x86Config.CachedDirectoryTableEntry,AL
  MOV AL,0E9h { CCR5 }
  OUT 22h,AL
  IN  AL,23h
  MOV BL,AL
  AND AL,1
  MOV ES:[DI].Cyrix6x86Config.WriteAllocate,AL
  SHR BL,1
  AND BL,1
  XOR BL,1
  MOV ES:[DI].Cyrix6x86Config.FastLoop,AL
 {$ENDIF}
END;

Procedure SetCyrix6x86Config(Var Q:Cyrix6x86Config);Assembler;ASM
 {$IFDEF FLAT386}
  LEA  EDI,DWord Ptr Q
  MOV  DX,0022h { Port de contr“le de configuration }
  MOV  AL,0C3h  { Registres de contr“le de configuration CCR3 }
  OUT  DX,AL
  INC  DX
  IN   AL,DX
  MOV  CL,AL    { Sauvegarde dans CL la valeur CCR3 }
   { Fixe les bits 4 … 7 du registre CCR3 … 1 pour autoriser une modification }
  AND  AL,0Fh
  OR   AL,010h
  XCHG AL,AH
  DEC  DX
  MOV  AL,0C3h  { Registre CCR3 }
  OUT  DX,AL
  INC  DX
  XCHG AL,AH
  OUT  DX,AL
  DEC  DX
  MOV  AL,0E8h
  OUT  DX,AL
  INC  DX
  IN   AL,DX
   { Ajuste le 7 bits du registre . la valeur de rX_ }
  MOV  CH,[EDI].Cyrix6x86Config.CPUID
  MOV  CPUID,CH
  CMP  CH,True
  JE   @2
  AND  AL,LOW(NOT 80h)
  JMP  @3
 @2:
  OR   AL,80h
 @3:
  XCHG AL,AH
  DEC  DX
  MOV  AL,0E8h
  OUT  DX,AL
  INC  DX
  XCHG AL,AH
  OUT  DX,AL
  DEC  DX
   { Restitution de la valeur original du CCR3 }
  MOV  AL,0C3h  { Registre CCR3 }
  OUT  DX,AL
  INC  DX
  MOV  AL,CL
  OUT  DX,AL
 {$ELSE}
  LES  DI,Q
  MOV  DX,0022h { Port de contr"le de configuration }
  MOV  AL,0C3h  { Registres de contr"le de configuration CCR3 }
  OUT  DX,AL
  INC  DX
  IN   AL,DX
  MOV  CL,AL    { Sauvegarde dans CL la valeur CCR3 }
   { Fixe les bits 4 … 7 du registre CCR3 … 1 pour autoriser une modification }
  AND  AL,0Fh
  OR   AL,010h
  XCHG AL,AH
  DEC  DX
  MOV  AL,0C3h  { Registre CCR3 }
  OUT  DX,AL
  INC  DX
  XCHG AL,AH
  OUT  DX,AL
  DEC  DX
  MOV  AL,0E8h
  OUT  DX,AL
  INC  DX
  IN   AL,DX
   { Ajuste le 7 bits du registre … la valeur de ®X¯ }
  MOV  CH,ES:[DI].Cyrix6x86Config.CPUID
  CMP  CH,True
  JE   @2
  AND  AL,LOW(NOT 80h)
  JMP  @3
 @2:
  OR   AL,80h
 @3:
  XCHG AL,AH
  DEC  DX
  MOV  AL,0E8h
  OUT  DX,AL
  INC  DX
  XCHG AL,AH
  OUT  DX,AL
  DEC  DX
   { Restitution de la valeur original du CCR3 }
  MOV  AL,0C3h  { Registre CCR3 }
  OUT  DX,AL
  INC  DX
  MOV  AL,CL
  OUT  DX,AL
 {$ENDIF}
END;

Procedure SetCPUIDFromCyrix(X:Boolean);Assembler;ASM
 MOV  DX,0022h { Port de contr“le de configuration }
 MOV  AL,0C3h  { Registres de contr“le de configuration CCR3 }
 OUT  DX,AL
 INC  DX
 IN   AL,DX
 MOV  CL,AL    { Sauvegarde dans CL la valeur CCR3 }
  { Fixe les bits 4 … 7 du registre CCR3. 1 pour autoriser une modification }
 AND  AL,0Fh
 OR   AL,010h
 XCHG AL,AH
 DEC  DX
 MOV  AL,0C3h  { Registre CCR3 }
 OUT  DX,AL
 INC  DX
 XCHG AL,AH
 OUT  DX,AL
 DEC  DX
 MOV  AL,0E8h
 OUT  DX,AL
 INC  DX
 IN   AL,DX
  { Ajuste le 7 bits du registre … la valeur de ®X¯ }
 CMP  X,True
 JE   @2
 AND  AL,LOW(NOT 80h)
 JMP  @3
@2:
 OR   AL,80h
@3:
 XCHG AL,AH
 DEC  DX
 MOV  AL,0E8h
 OUT  DX,AL
 INC  DX
 XCHG AL,AH
 OUT  DX,AL
 DEC  DX
  { Restitution de la valeur original du CCR3 }
 MOV  AL,0C3h  { Registre CCR3 }
 OUT  DX,AL
 INC  DX
 MOV  AL,CL
 OUT  DX,AL
END;

END.