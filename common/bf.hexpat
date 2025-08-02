#include <std/core.pat>
#include <std/io.pat>


import * from atlus.common.bmd as BMD;

enum Endianness : u16 {
    Little,
    Big
};

struct Header
{
    u8 FileType;
    bool Compressed;
    u16 UserId;
    u32 FileSize;
    char Magic[4];
    padding[4];
    u32 SectionCount;
    u16 LocalIntVariableCount;
    u16 LocalFloatVariableCount;
    Endianness Endianness;
    padding[6];
};

enum SectionType : u32
{
    ProcedureLabelSection,
    JumpLabelSection,
    TextSection,
    MessageScriptSection,
    StringSection
};

struct SectionHeader
{
    SectionType Type;
    u32 ElementSize;
    u32 ElementCount;
    u32 FirstElementAddress;
};

struct Label<auto size>
{   
    char Name[size - 8];
    u32 InstructionIndex;
    u32 Reserved;   
};

struct LabelSection<auto header>
{
    Label<header.ElementSize> Labels[header.ElementCount];
};

enum Opcode : u16
{
    PUSHI,
    PUSHF,
    PUSHIX,
    PUSHIF,
    PUSHREG,
    POPIX,
    POPFX,
    PROC,
    COMM,
    END,
    JUMP,
    CALL,
    RUN,
    GOTO,
    ADD,
    SUB,
    MUL,
    DIV,
    MINUS,
    NOT,
    OR,
    AND,
    EQ,
    NEQ,
    S,
    L,
    SE,
    LE,
    IF,
    PUSHIS,
    PUSHLIX,
    PUSHLFX,
    POPLIX,
    POPLFX,
    PUSHSTR,
    POPREG
};

union Instruction
{
    Opcode Opcode;
    
    // TODO it is not actually this simple, not all operands are u32, many are u16. If anyone cares, fix this up. Use script tools for reference
    if ( Opcode == Opcode::PUSHF ) {
        float Operand;
    } else {
        u32 Operand;
    }
};

struct TextSection<auto header>
{
  Instruction Instructions[header.ElementCount];  
};

struct StringSection<auto size>
{
    u8 Data[size];
};

struct Section<auto headers>
{
    match (headers[std::core::array_index()].Type)
    {
        (SectionType::ProcedureLabelSection | SectionType::JumpLabelSection): LabelSection<headers[std::core::array_index()]> Section;
        (SectionType::TextSection): TextSection<headers[std::core::array_index()]> Section;
        (SectionType::MessageScriptSection): BMD Section;
        (SectionType::StringSection): StringSection<headers[std::core::array_index()].ElementCount> Section;
    }
};

struct File
{
    Header Header;
    
    if (Header.Endianness == 0) {
        std::core::set_endian(std::mem::Endian::Little);
    } else {
        std::core::set_endian(std::mem::Endian::Big);
    }
    
    SectionHeader SectionHeaders[Header.SectionCount];
    Section<SectionHeaders> Sections[Header.SectionCount];
};

File File @ 0 [[inline]];