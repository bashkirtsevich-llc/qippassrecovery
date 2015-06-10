unit OSCARMd5;

(*
  OSCARMd5 part of OSCARIndex library.
  OSCARIndex — OSCAR Protocol Library for Delphi                        / VCL
                                                                        / DLL
                                                                        / COM  
  (C) 2006, 5190@mail.ru



  Changelog:

  09.12.2006 [-/c]: OSCARBase64 & hij temp removed;
  13.11.2006 [+/c]: Pointer in oscarmd5__encode_pass for ticqclient;
  13.11.2006 [-/c]: modBuild temp removed;

*)


//  modBuild version information
// {$I *.inc}  //     d:/develop/projects/OSCARIndex_win32_x86/debug/build/

interface

uses
	Windows, Classes;

const
  modVersion = 'OSCARMd5 version %s/%d.%d.%d.%d';

type
	MD5Count  = array[0..1]  of DWord;
	MD5State  = array[0..3]  of DWord;
	MD5Block  = array[0..15] of DWord;
	MD5CBits  = array[0..7]  of Byte;
	MD5Digest = array[0..15] of Byte;
	MD5Buffer = array[0..63] of Byte;

	MD5Context = record
		State: MD5State;
		Count: MD5Count;
		Buffer: MD5Buffer;
	end;

procedure MD5Init(var Context: MD5Context);
procedure MD5Append(var Context: MD5Context; Input: PChar; Length: longword);
procedure MD5Final(var Context: MD5Context; var Digest: MD5Digest);
function  oscarmd5__encode_pass(Password, Key: string; hversion: Byte): Pointer;

implementation

var
	PADDING: MD5Buffer = (
		$80, $00, $00, $00, $00, $00, $00, $00,
		$00, $00, $00, $00, $00, $00, $00, $00,
		$00, $00, $00, $00, $00, $00, $00, $00,
		$00, $00, $00, $00, $00, $00, $00, $00,
		$00, $00, $00, $00, $00, $00, $00, $00,
		$00, $00, $00, $00, $00, $00, $00, $00,
		$00, $00, $00, $00, $00, $00, $00, $00,
		$00, $00, $00, $00, $00, $00, $00, $00
	);

(******************************************************************************)
  function F(x, y, z: DWord): DWord;
begin
	Result := (x and y) or ((not x) and z);
end;

(******************************************************************************)
function G(x, y, z: DWord): DWord;
begin
	Result := (x and z) or (y and (not z));
end;

(******************************************************************************)
function H(x, y, z: DWord): DWord;
begin
	Result := x xor y xor z;
end;

(******************************************************************************)
function I(x, y, z: DWord): DWord;
begin
	Result := y xor (x or (not z));
end;

(******************************************************************************)
procedure rot(var x: DWord; n: Byte);
begin
	x := (x shl n) or (x shr (32 - n));
end;

(******************************************************************************)
procedure FF(var a: DWord; b, c, d, x: DWord; s: Byte; ac: DWord);
begin
	inc(a, F(b, c, d) + x + ac);
	rot(a, s);
	inc(a, b);
end;

(******************************************************************************)
procedure GG(var a: DWord; b, c, d, x: DWord; s: Byte; ac: DWord);
begin
	inc(a, G(b, c, d) + x + ac);
	rot(a, s);
	inc(a, b);
end;

(******************************************************************************)
procedure HH(var a: DWord; b, c, d, x: DWord; s: Byte; ac: DWord);
begin
	inc(a, H(b, c, d) + x + ac);
	rot(a, s);
	inc(a, b);
end;

(******************************************************************************)
procedure II(var a: DWORD; b, c, d, x: DWORD; s: BYTE; ac: DWORD);
begin
	inc(a, I(b, c, d) + x + ac);
	rot(a, s);
	inc(a, b);
end;

(******************************************************************************)
procedure Encode(Source, Target: Pointer; Count: LongWord);
var
	S: PByte;
	T: PDWORD;
	I: longword;
begin
	S := Source;
	T := Target;
	for I := 1 to Count div 4 do begin
		T^ := S^;
		inc(S);
		T^ := T^ or (S^ shl 8);
		inc(S);
		T^ := T^ or (S^ shl 16);
		inc(S);
		T^ := T^ or (S^ shl 24);
		inc(S);
		inc(T);
	end;
end;

(******************************************************************************)
procedure Decode(Source, Target: Pointer; Count: LongWord);
var
	S: PDWORD;
	T: PByte;
	I: longword;
begin
	S := Source;
	T := Target;
	for I := 1 to Count do begin
		T^ := S^ and $ff;
		inc(T);
		T^ := (S^ shr 8) and $ff;
		inc(T);
		T^ := (S^ shr 16) and $ff;
		inc(T);
		T^ := (S^ shr 24) and $ff;
		inc(T);
		inc(S);
	end;
end;

(******************************************************************************)
procedure Transform(Buffer: Pointer; var State: MD5State);
var
	a, b, c, d: DWORD;
	Block: MD5Block;
begin
	Encode(Buffer, @Block, 64);
	a := State[0];
	b := State[1];
	c := State[2];
	d := State[3];
	FF (a, b, c, d, Block[ 0],  7, $d76aa478);
	FF (d, a, b, c, Block[ 1], 12, $e8c7b756);
	FF (c, d, a, b, Block[ 2], 17, $242070db);
	FF (b, c, d, a, Block[ 3], 22, $c1bdceee);
	FF (a, b, c, d, Block[ 4],  7, $f57c0faf);
	FF (d, a, b, c, Block[ 5], 12, $4787c62a);
	FF (c, d, a, b, Block[ 6], 17, $a8304613);
	FF (b, c, d, a, Block[ 7], 22, $fd469501);
	FF (a, b, c, d, Block[ 8],  7, $698098d8);
	FF (d, a, b, c, Block[ 9], 12, $8b44f7af);
	FF (c, d, a, b, Block[10], 17, $ffff5bb1);
	FF (b, c, d, a, Block[11], 22, $895cd7be);
	FF (a, b, c, d, Block[12],  7, $6b901122);
	FF (d, a, b, c, Block[13], 12, $fd987193);
	FF (c, d, a, b, Block[14], 17, $a679438e);
	FF (b, c, d, a, Block[15], 22, $49b40821);
	GG (a, b, c, d, Block[ 1],  5, $f61e2562);
	GG (d, a, b, c, Block[ 6],  9, $c040b340);
	GG (c, d, a, b, Block[11], 14, $265e5a51);
	GG (b, c, d, a, Block[ 0], 20, $e9b6c7aa);
	GG (a, b, c, d, Block[ 5],  5, $d62f105d);
	GG (d, a, b, c, Block[10],  9,  $2441453);
	GG (c, d, a, b, Block[15], 14, $d8a1e681);
	GG (b, c, d, a, Block[ 4], 20, $e7d3fbc8);
	GG (a, b, c, d, Block[ 9],  5, $21e1cde6);
	GG (d, a, b, c, Block[14],  9, $c33707d6);
	GG (c, d, a, b, Block[ 3], 14, $f4d50d87);
	GG (b, c, d, a, Block[ 8], 20, $455a14ed);
	GG (a, b, c, d, Block[13],  5, $a9e3e905);
	GG (d, a, b, c, Block[ 2],  9, $fcefa3f8);
	GG (c, d, a, b, Block[ 7], 14, $676f02d9);
	GG (b, c, d, a, Block[12], 20, $8d2a4c8a);
	HH (a, b, c, d, Block[ 5],  4, $fffa3942);
	HH (d, a, b, c, Block[ 8], 11, $8771f681);
	HH (c, d, a, b, Block[11], 16, $6d9d6122);
	HH (b, c, d, a, Block[14], 23, $fde5380c);
	HH (a, b, c, d, Block[ 1],  4, $a4beea44);
	HH (d, a, b, c, Block[ 4], 11, $4bdecfa9);
	HH (c, d, a, b, Block[ 7], 16, $f6bb4b60);
	HH (b, c, d, a, Block[10], 23, $bebfbc70);
	HH (a, b, c, d, Block[13],  4, $289b7ec6);
	HH (d, a, b, c, Block[ 0], 11, $eaa127fa);
	HH (c, d, a, b, Block[ 3], 16, $d4ef3085);
	HH (b, c, d, a, Block[ 6], 23,  $4881d05);
	HH (a, b, c, d, Block[ 9],  4, $d9d4d039);
	HH (d, a, b, c, Block[12], 11, $e6db99e5);
	HH (c, d, a, b, Block[15], 16, $1fa27cf8);
	HH (b, c, d, a, Block[ 2], 23, $c4ac5665);
	II (a, b, c, d, Block[ 0],  6, $f4292244);
	II (d, a, b, c, Block[ 7], 10, $432aff97);
	II (c, d, a, b, Block[14], 15, $ab9423a7);
	II (b, c, d, a, Block[ 5], 21, $fc93a039);
	II (a, b, c, d, Block[12],  6, $655b59c3);
	II (d, a, b, c, Block[ 3], 10, $8f0ccc92);
	II (c, d, a, b, Block[10], 15, $ffeff47d);
	II (b, c, d, a, Block[ 1], 21, $85845dd1);
	II (a, b, c, d, Block[ 8],  6, $6fa87e4f);
	II (d, a, b, c, Block[15], 10, $fe2ce6e0);
	II (c, d, a, b, Block[ 6], 15, $a3014314);
	II (b, c, d, a, Block[13], 21, $4e0811a1);
	II (a, b, c, d, Block[ 4],  6, $f7537e82);
	II (d, a, b, c, Block[11], 10, $bd3af235);
	II (c, d, a, b, Block[ 2], 15, $2ad7d2bb);
	II (b, c, d, a, Block[ 9], 21, $eb86d391);
	inc(State[0], a);
	inc(State[1], b);
	inc(State[2], c);
	inc(State[3], d);
end;

(******************************************************************************)
procedure MD5Init(var Context: MD5Context);
begin
	with Context do begin
		State[0] := $67452301;
		State[1] := $efcdab89;
		State[2] := $98badcfe;
		State[3] := $10325476;
		Count[0] := 0;
		Count[1] := 0;
		ZeroMemory(@Buffer, SizeOf(MD5Buffer));
	end;
end;

(******************************************************************************)
procedure MD5Append(var Context: MD5Context; Input: PChar; Length: LongWord);
var
	Index: longword;
	PartLen: longword;
	I: longword;
begin
	with Context do begin
		Index := (Count[0] shr 3) and $3f;
		inc(Count[0], Length shl 3);
		if Count[0] < (Length shl 3) then inc(Count[1]);
		inc(Count[1], Length shr 29);
	end;
	PartLen := 64 - Index;
	if Length >= PartLen then begin
		CopyMemory(@Context.Buffer[Index], Input, PartLen);
		Transform(@Context.Buffer, Context.State);
		I := PartLen;
		while I + 63 < Length do begin
			Transform(@Input[I], Context.State);
			inc(I, 64);
		end;
		Index := 0;
	end else I := 0;
	CopyMemory(@Context.Buffer[Index], @Input[I], Length - I);
end;

(******************************************************************************)
procedure MD5Final(var Context: MD5Context; var Digest: MD5Digest);
var
	Bits: MD5CBits;
	Index: longword;
	PadLen: longword;
begin
	Decode(@Context.Count, @Bits, 2);
	Index := (Context.Count[0] shr 3) and $3f;
	if Index < 56 then PadLen := 56 - Index else PadLen := 120 - Index;
	MD5Append(Context, @PADDING, PadLen);
	MD5Append(Context, @Bits, 8);
	Decode(@Context.State, @Digest, 4);
	ZeroMemory(@Context, SizeOf(MD5Context));
end;

(******************************************************************************)
function oscarmd5__encode_pass(Password, Key: string; hversion: Byte): Pointer;
const
  AIM_COSCAR_STRING = 'AOL Instant Messenger (SM)';  
var
  md5C: MD5Context;
  z, PassDigest: MD5Digest;
begin
  MD5Init(md5C);
  case hversion of
    1:
    begin
      MD5Append(md5C, PChar(Key), Length(Key));
      MD5Append(md5C, PChar(Password), Length(Password));
      MD5Append(md5C, PChar(AIM_COSCAR_STRING), Length(AIM_COSCAR_STRING));
    end;
    2:
    begin
      MD5Append(md5C, PChar(Password), Length(Password));
      MD5Final(md5C, PassDigest);
      MD5Init(md5C);
      MD5Append(md5C, PChar(Key), Length(Key));
      MD5Append(md5C, @PassDigest, 16);
      MD5Append(md5C, PChar(AIM_COSCAR_STRING), Length(AIM_COSCAR_STRING));
    end;
    3:
    begin
      HexToBin(PChar(Password), PChar(@z), Length(z));
      MD5Append(md5C, PChar(Key), Length(Key));
      MD5Append(md5C, @z, 16);
      MD5Append(md5C, PChar(AIM_COSCAR_STRING), Length(AIM_COSCAR_STRING));
    end;
    4:
    begin
      //  hijakers
    end;
    5:
    begin
      //  base64
    end;
  end;
  MD5Final(md5C, PassDigest);
  Result := @PassDigest;  
end;


end.

