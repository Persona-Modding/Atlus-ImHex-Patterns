struct MsgHeader
{
    u8 FileFormat;
    u8 Format;
    u16 UserId;
    u32 FileSize;
    char Magic[4];
    u32 ExtSize;
    u32 RelocationTableOffset;
    u32 RelocationTableSize;
    u32 DialogCount;
    u16 IsRelocated;
    u16 Version;
};

enum DialogKind : u32
{
    Message,
    Selection
};

struct MessageDialog
{
    char Name[24];
    u16 PageCount;
    s16 SpeakerId;
    u32 PageStartAddrsses[PageCount];
    u32 TextBufferSize;
    u8 TextBuffer[TextBufferSize];
};

enum SelectionPattern : u16
{
    Top,
    Bottom
};

struct SelectionDialog
{
    char Name[24];
    u16 Ext;
    u16 OptionCount;
    SelectionPattern Pattern;
    u16 Reserved;
    u32 OptionStartAddresses[OptionCount];
    u32 TextBufferSize;
    u8 TextBuffer[TextBufferSize];
};

fn relative_to_bmd(u128 offset)
{
    return sizeof(MsgHeader);
};

struct DialogHeader
{

    DialogKind Kind;
    match(Kind)
    {
        (DialogKind::Message): MessageDialog* Message : u32[[pointer_base("relative_to_bmd")]];
        (DialogKind::Selection): SelectionDialog* Selection : u32[[pointer_base("relative_to_bmd")]];
    }
};

struct SpeakerName
{
    char* SpeakerName[] : u32 [[pointer_base("relative_to_bmd")]];
} [[inline]];

struct SpeakerTableHeader
{
    u32 SpeakerNameArrayOffset;
    u32 SpeakerCount;
    u32 ExtDataOffset;
    u32 Reserved;
    SpeakerName SpeakerNames[SpeakerCount] @ SpeakerNameArrayOffset + addressof(parent) + 32;
};

struct MessageScript
{
    MsgHeader Header;
    DialogHeader DialogHeaders[Header.DialogCount];
    SpeakerTableHeader SpeakerTableHeader;
    u8 RelocationTable[Header.RelocationTableSize] @ Header.RelocationTableOffset + addressof(this);
    $ = addressof(this) + Header.FileSize;
};

MessageScript File @ 0 [[inline]];