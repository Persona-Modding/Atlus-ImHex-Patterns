#pragma author Rirurin
#pragma description Template for reading event files from Metaphor: Refantazio (EVT and ECS)

#include <hex/provider.pat>
#include <std/io.pat>
#include <std/string.pat>
#include <std/sys.pat>
#include <atlus/metaphor/common/colors.hexpat>
#include <atlus/p5r/common/numerics.expat>

using f32 = float;

fn fmt_fixed_length_string(ref str data) {
    return std::format("{}", data);
};

struct EvtHeader {
    char Magic[3];
    u8 Endian;
    u32 Version;
    u16 MajorID;
    u16 MinorID;
    u8 Rank;
    u8 Level;
    u8 Chapter;
    u8 Field0F[[hidden]];
    u32 FileSize;
    u32 FileHeaderSize;
    u32 Flags;
    s32 TotalFrame;
    u8 FrameRate;
    u8 InitScriptIndex;
    u16 StartFrame;
    u16 LetterBoxInFrame;
    u16 Field26[[hidden]];
    u32 InitEnvAssetID;
    u32 InitEnvAssetIDDbg;
    u32 AssetNums;
    u32 AssetDataOfs;
    u32 AssetDataSize;
    u32 AssetReserve;
    u32 CommandNums;
    u32 CommandHeaderOfs;
    u32 CommandHeaderSize;
    u32 CommandReserve;
    u32 MessagePathOfs;
    u32 MessagePathSize;
    u32 MessageFileOfs;
    u32 MessageFileSize;
    u32 ScriptPathOfs;
    u32 ScriptPathSize;
    u32 ScriptFileOfs;
    u32 ScriptFileSize;
    u32 MarkerFrame[8];
    char InitScriptFilename[0x40][[format("fmt_fixed_length_string")]];
    s32 TimeIndex;
    s32 WeatherIndex;
    s32 IgniterBGIndex;
    s32 WipeIndex;
    s32 IgniterPathIndex;
    u8 Padding[FileHeaderSize - 0xe4][[hidden]];
}[[format("fmt_evt_header")]];

fn fmt_evt_header(ref EvtHeader self) {
    return std::format("VER: 0x{:x}, ID: e{:02}_{:03}_{:03}, RANK: {}, LEVEL: {}", self.Version, self.Chapter, self.MajorID, self.MinorID, self.Rank, self.Level);
};

struct EcsHeader {
    u32 CommandNums;
    u32 CommandHeaderOfs;
    u32 CommandHeaderSize;
    u32 CommandReserve;
}[[static]];

struct Animation {
    s32 Type;
    s32 Category;
    s32 Chapter;
    s32 Major;
    s32 Minor;
    s32 Sub;
    char FilePath[256][[format("fmt_fixed_length_string")]];
}[[static]];

struct Object {
    s32 AssetID;
    s32 ResrcTypeID;
    s32 ResrcCategory;
    s32 ResrcUniqueID;
    s32 ResrcMajorID;
    s16 ResrcSubID;
    s16 ResrcMinorID;
    u32 Flags;
    u32 BaseMotNo;
    u32 ExtBaseMotNo;
    Animation baseAnimData;
    Animation baseAnimExtData;
    Animation additiveAnimData;
    Animation facialAnimData;
    u32 Field464;
    u32 Field468;
    u32 TexIndex;
    char OverwriteLabel[64][[format("fmt_fixed_length_string")]];
    char CaptureLabel[64][[format("fmt_fixed_length_string")]];
}[[name(std::format("ID: {}", AssetID))]];

// Command types (mostly) automatically generated from script in xrd759-inspector/detail_panel/event.rs (Metaphor Multiplayer)

struct CAMERA_MOVE_DIRECT {
    u32 Flags; // 0x0
    vector3 Pos; // 0x4
    euler AngleDeg; // 0x10
    f32 FovY; // 0x1c
    padding[8];
    u32 InterpParam; // 0x28
    f32 FocalPlane; // 0x2c
    f32 NearPlaneOffset; // 0x30
    f32 FarPlaneOffset; // 0x34
    f32 FarBlurLimit; // 0x38
    f32 BlurSize; // 0x3c
    f32 BlurAngle; // 0x40
    padding[4];
    f32 BokehDistance; // 0x48
};

struct CAMERA_SET_ASSET {
    u32 Flags; // 0x0
    u32 AssetID; // 0x4
    s32 AnimNo; // 0x8
    f32 AnimSpeed; // 0xc
    s32 AnimStartFrame; // 0x10
    vector3 Pos; // 0x14
    euler AngleDeg; // 0x20
    padding[4];
    f32 FocalPlane; // 0x30
    f32 NearPlaneOffset; // 0x34
    f32 FarPlaneOffset; // 0x38
    f32 FarBlurLimit; // 0x3c
    f32 BlurSize; // 0x40
    f32 BlurAngle; // 0x44
    padding[4];
    f32 BokehDistance; // 0x4c
    padding[0x14];
    f32 NearClipPlane; // 0x60
    f32 FarClipPlane; // 0x64
};

struct CAMERA_SET_DIRECT {
    u32 Flags; // 0x0
    vector3 Pos; // 0x4
    euler AngleDeg; // 0x10
    f32 FovY; // 0x1c
    padding[8];
    f32 FocalPlane; // 0x28
    f32 NearPlaneOffset; // 0x2c
    f32 FarPlaneOffset; // 0x30
    f32 FarBlurLimit; // 0x34
    f32 BlurSize; // 0x38
    f32 BlurAngle; // 0x3c
    padding[4];
    f32 BokehDistance; // 0x44
    padding[4];
    f32 NearClipPlane; // 0x4c
    f32 FarClipPlane; // 0x50
};

struct CAMERA_SET_FIELD {
    u32 Flags; // 0x0
    s32 AssetID; // 0x4
    s32 CameraUID; // 0x8
    f32 FocalPlane; // 0xc
    f32 NearPlaneOffset; // 0x10
    f32 FarPlaneOffset; // 0x14
    f32 FarBlurLimit; // 0x18
    f32 BlurSize; // 0x1c
    f32 BlurAngle; // 0x20
    f32 BokehDistance; // 0x24
};

struct CAMERA_SHAKE {
    u32 Flags; // 0x0
    s32 Mode; // 0x4
    s32 Type; // 0x8
    f32 Scale; // 0xc
    f32 Speed; // 0x10
};

struct EFFECT_ALPHA {
    u32 Flags; // 0x0
    padding[3];
    u8 AlphaValue; // 0x7
    u32 InterpParam; // 0x8
};

struct EFFECT_REGISTER {
    u32 Flags; // 0x0
    u32 RegisterType; // 0x4
    u32 SceneType; // 0x8
};

struct EFFECT_SCALE {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    f32 Scale; // 0x8
};

struct EFFECT_SET_DIRECT {
    u32 Flags; // 0x0
    vector3 Pos; // 0x4
    euler AngleDeg; // 0x10
};

struct EFFECT_SET_HELPER {
    u32 Flags; // 0x0
    u16 FrameLengthIn; // 0x4
    u16 FrameLengthOut; // 0x6
    u32 InterpParamIn; // 0x8
    u32 InterpParamOut; // 0xc
    u32 TargetAssetID; // 0x10
    u32 HelperID; // 0x14
};

struct ENV_CLOUD {
    u32 Flags; // 0x0
    f32 GlobalDensity; // 0x4
    f32 Phase; // 0x8
    f32 Coverage; // 0xc
    f32 Type; // 0x10
    f32 Wetness; // 0x14
    f32 WindSpeed; // 0x18
    f32 WindAngle; // 0x1c
    s32 StepMaxNum; // 0x20
    padding[4];
    f32RGBA Color; // 0x28
};

struct ENV_DIFFUSION {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    f32 Scale; // 0x8
    f32 Bias; // 0xc
};

struct ENV_PLANE_GRADATION {
    u32 Flags; // 0x0
    vector3 PlanePos; // 0x4
    f32 PlaneDistance; // 0x10
    euler PlaneRot; // 0x14
    f32RGB LightColor; // 0x20
    f32RGB ShadowColor; // 0x2c
    f32 Attenuation; // 0x38
    f32 Factor; // 0x3c
};

struct ENV_SET {
    u32 Flags; // 0x0
    u32 AssetID; // 0x4
};

struct ENV_BGCOLOR {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    padding[4];
    u8RGBA ColorRGBA; // 0xc
};

struct ENV_CORRECT {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    f32 Cyan; // 0x8
    f32 Magenta; // 0xc
    f32 Yellow; // 0x10
    f32 Dodge; // 0x14
    f32 Burn; // 0x18
};

struct ENV_DOF {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    f32 FocalPlane; // 0x8
    f32 NearPlaneOffset; // 0xc
    f32 FarPlaneOffset; // 0x10
    f32 FarBlurLimit; // 0x14
    f32 BlurSize; // 0x18
    f32 BlurAngle; // 0x1c
    padding[8];
    f32 BokehDistance; // 0x24
};

struct ENV_EXPONENTIAL_FOG {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    f32 FogHeight; // 0x8
    f32 FogDensity; // 0xc
    f32 FogHeightFalloff; // 0x10
    f32 FogMaxOpacity; // 0x14
    f32 StartDistance; // 0x18
    f32 LightTerminatorAngle; // 0x1c
    f32RGB FogColor; // 0x20
    f32 FogColorIntensity; // 0x2c
    f32 DirInscatExponent; // 0x30
    padding[4];
    f32RGB DirInscatColor; // 0x38
    f32 DirInscatStartDistance; // 0x34
    padding[12];
    f32 DirInscatColorIntensity; // 0x44
};

struct ENV_HDR {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    padding[8];
    f32 ToonIntensity; // 0x10
    f32 BloomScale; // 0x14
    f32 AdaptedLum; // 0x18
    f32 ElapsedTime; // 0x1c
    s32 StarNumLines; // 0x20
    f32 StarLength; // 0x24
    f32 StarScale; // 0x28
    f32 StarGlareCA; // 0x2c
    f32 StarGlareSI; // 0x30
    f32 DiffusionMiddleGray; // 0x34
    f32 DiffusionScale; // 0x38
    f32 DiffusionAdaptedLum; // 0x3c
};

struct ENV_LIGHT_0 {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    f32 Intensity; // 0x8
    u8RGBA AmbientColorRGBA; // 0x10
    u8RGBA DiffuseColorRGBA; // 0x14
    u8RGBA SpecularColorRGBA; // 0x18
    vector3 DirVec; // 0x1c
};

struct ENV_LIGHT_1 {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    f32 ColorIntensity; // 0x8
    f32 SpecularIntensity; // 0xc
    u8RGBA AmbientColorRGBA; // 0x10
    u8RGBA DiffuseColorRGBA; // 0x14
    padding[4];
    vector3 DirVec; // 0x1c
};

struct ENV_OUTLINE {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    f32 Range; // 0x8
    f32 Width; // 0xc
    f32 Brightness; // 0x10
    f32 GeometryRangeStart; // 0x14
    f32 GeometryRangeEnd; // 0x18
    f32 ThinMax; // 0x1c
    f32 ThinFadeStart; // 0x20
    f32 ThinFadeEnd; // 0x24
};

struct ENV_PHYSICS {
    u32 Flags; // 0x0
};

struct ENV_SHADOW {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    padding[8];
    u32 ShadowFlags; // 0x10
    f32 DepthRange; // 0x14
    f32 BiasPBR; // 0x18
    f32 BiasOther; // 0x1c
    f32 Split; // 0x20
    f32 BorderTile; // 0x24
    f32 BorderScale; // 0x28
    f32 PatternTile; // 0x2c
    f32 PatternAlpha; // 0x30
    f32 Alpha; // 0x34
};

struct ENV_SKYDOME {
    u32 Flags; // 0x0
};

struct ENV_SSAO {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    padding[8];
    f32 DepthRange; // 0x10
    f32 OccluderRadius; // 0x14
    f32 FalloffRadius; // 0x18
    f32 Brightness; // 0x1c
    f32 BlurScale; // 0x20
};

struct FADE {
    u32 Flags; // 0x0
    u8 ActionIndex; // 0x4
    u8 ColorIndex; // 0x5
    padding[2];
    s32 FadeOutOpIndices[10];
    s32 FadeRate; // 0x30
    s32 AnimTypeIndex; // 0x34
    s32 BlendTypeIndex; // 0x38
    u32 CustomColor; // 0x3c
};

struct FIELD_FEATURE_DISP {
    u32 Flags; // 0x0
};

struct FIELD_LIGHTS {
    u32 Flags; // 0x0
    f32 IntensityScale; // 0x4
};

struct FIELD_MOB_DISP {
    u32 Flags; // 0x0
};

struct FIELD_MOB_DISP_BOX {
    u32 Flags; // 0x0
    vector3 Pos; // 0x4
    euler AngleDeg; // 0x10
    vector3 Scale; // 0x1c
};

struct FIELD_OBJ_ANIM_BASE {
    u32 Flags; // 0x0
    s32 ObjectIDTypeIndex; // 0x4
    s32 ObjectID; // 0x8
    s32 AnimNo; // 0xc
    s32 AnimStartFrame; // 0x10
    s32 AnimEndFrame; // 0x14
    s32 AnimBlendFrame; // 0x18
    s32 AnimFlags; // 0x1c
    f32 AnimSpeed; // 0x20
};

struct FIELD_OBJ_DISP {
    u32 Flags; // 0x0
    s32 ObjectID; // 0x4
    s32 ObjectIDTypeIndex; // 0x8
};

struct FIELD_SET {
    u32 Flags; // 0x0
    s32 DivNo; // 0x4
    padding[8];
    vector3 Pos; // 0x10
    euler RotDeg; // 0x1c
    vector3 RotBasePos; // 0x28
};

struct FRAME_JUMP {
    s32 Frame; // 0x0
};

struct FRAME_UNSKIPPABLE {
    u32 Flags; // 0x0
};

struct GAME_BASE_PARAM_UP {
    u32 Flags; // 0x0
    s32 CharaIDIndex; // 0x4
    s32 ParamIndex; // 0x8
    s32 Value; // 0xc
    s32 ReferredEnumLength; // 0x10
    char ReferredEnumName[0x40][[format("fmt_fixed_length_string")]]; // 0x14
};

struct GAME_DATE {
    u32 Flags; // 0x0
    s32 MonthIndex; // 0x4
    s32 Day; // 0x8
    s32 TimeIndex; // 0xc
    s32 WeatherIndex; // 0x10
    s32 Temperature; // 0x18
};

struct GAME_FOLLOWER_RANK_UP {
    u32 FollowerIndex; // 0x0
    u32 FollowerRank; // 0x4
};

struct GAME_HUMAN_PARAM_UP {
    u32 Flags; // 0x0
    s32 HeroAssetId; // 0x4
    s32 ParamIndex; // 0x8
    s32 ParamValue; // 0xc
    s32 IconSizeIndex; // 0x10
    padding[4];
    f32 IconScale; // 0x18
    vector3 IconPosOffset; // 0x1c
    s32 ReferredEnumLength; // 0x28
    char ReferredEnumName[0x40][[format("fmt_fixed_length_string")]]; // 0x2c
};

struct ItemLabelName {
    char Name[0x40][[format("fmt_fixed_length_string")]];
}[[format("fmt_item_label_name")]];

fn fmt_item_label_name(ref ItemLabelName self) {
    return std::format("{}", self.Name);
};

struct GAME_ITEM {
    u32 Flags; // 0x0
    s32 PositionIndex; // 0x4
    s32 ItemCounts[8]; // 0x8
    s32 LabelLengths[8]; // 0x28
    ItemLabelName LabelNames[8]; // 0x48
    s32 ReferredEnumLength; // 0x248
    char ReferredEnumName[0x40][[format("fmt_fixed_length_string")]]; // 0x24c
};

struct GAME_AREA_NAME {
    u32 Flags; // 0x0
};

struct GAME_MONEY {
    u32 Flags; // 0x0
    s32 Money; // 0x4
    s32 ReferredEnumLength; // 0x8
    char ReferredEnumName[0x40][[format("fmt_fixed_length_string")]];
};

struct GAME_NAME_ENTRY {
    u32 Flags; // 0x0
};

struct GAME_PLAYER_NAME_ENTRY {
    u32 Flags; // 0x0
};

struct GAME_QUEST {
    u32 Flags; // 0x0
    s32 TypeIndex; // 0x4
    s32 LabelLength; // 0x8
    char LabelName[0x40][[format("fmt_fixed_length_string")]];
};

struct GAME_SORTIE_MAP {
    u32 Flags; // 0x0
    s32 MapZoneIDIndex; // 0x4
    s32 MapPointId; // 0x8
};

struct GAME_TUTORIAL {
    u32 Flags; // 0x0
    s32 LabelLength; // 0x4
    char LabelName[0x40][[format("fmt_fixed_length_string")]];
};

struct MASK_BLEND {
    u32 Flags; // 0x0
    s32 BlendMode; // 0x8
    f32 Alpha; // 0xc
    vector2 UVPos; // 0x10
    vector2 UVScale; // 0x18
    f32 UVRotate; // 0x20
    s32 TexAddressMode; // 0x24
    padding[4];
    f32 UVCenterX; // 0x2c
    f32 UVCenterY; // 0x30
};

struct MASK_LAYER_BLEND {
    u32 Flags; // 0x0
    s32 MaskId; // 0x4
    s32 Priority; // 0x8
    s32 BlendMode; // 0xc
    f32 Alpha; // 0x10
    vector2 UVPos; // 0x14
    vector2 UVScale; // 0x1c
    f32 UVRotate; // 0x24
    s32 TexAddressMode; // 0x28
    padding[4];
    f32 UVCenterX; // 0x30
    f32 UVCenterY; // 0x34
};

struct MESSAGE {
    u32 Flags; // 0x0
    u16 MsgLabelMajorID; // 0x4
    u8 MsgLabelMinorID; // 0x6
    u8 MsgLabelSubID; // 0x7
    u16 SelLabelMajorID; // 0x8
    u8 SelLabelMinorID; // 0xa
    u8 SelLabelSubID; // 0xb
    u32 SetResultIndex; // 0xc
    u16 MsgForceEndWait; // 0x10
    s32 BustupFaceIndex; // 0x14
    s32 BustupOptionIndex; // 0x18
    s32 BustupCostumeIndex; // 0x1c
    s32 LipSyncModelUID; // 0x20
    s32 FollowerIndex; // 0x24
    s32 FollowerFriendship; // 0x28
};

struct MESSAGE_VOICE {
    u32 Flags; // 0x0
    s32 MsgLabelMajorID; // 0x4
    s32 MsgLabelSubID; // 0x8
    s32 LipSyncModelUID; // 0xc
};

struct SUBTITLE {
    u32 Flags; // 0x0
    s32 LabelId; // 0x4
    s32 LabelSubId; // 0x8
    s32 LipSyncModelUID; // 0xc
};

struct MOB_ANIM_BASE {
    u32 Flags; // 0x0
    s32 AnimNo; // 0x4
    s32 AnimStartFrame; // 0x8
    s32 AnimEndFrame; // 0xc
    s32 AnimBlendFrame; // 0x10
    s32 AnimFlags; // 0x14
    f32 AnimSpeed; // 0x18
    s32 StartIntervalSeed; // 0x1c
    s32 StartIntervalFrame; // 0x20
    s32 StartFrameRandomMax; // 0x24
};

struct MOB_ICON {
    u32 Flags; // 0x0
    s32 IconTypeIndex; // 0x4
    s32 IconSizeIndex; // 0x8
    f32 Scale; // 0xc
    vector3 PosOffset; // 0x10
};

struct MOB_LOOKAT {
    u32 Flags; // 0x0
    s32 ControlTypeIndex; // 0x4
    s32 SpeedTypeIndex; // 0x8
    vector3 LocalPos; // 0xc
    s32 StartIntervalSeed; // 0x18
    s32 StartIntervalFrame; // 0x1c
};

struct MOB_SET_DIRECT {
    u32 Flags; // 0x0
    vector3 Pos; // 0x4
    euler AngleDeg; // 0x10
    s32 AnimStartFrameSeed; // 0x20
    s32 AnimStartFrameOffset; // 0x24
};

struct MOB_REGISTER {
    u32 Flags; // 0x0
    u32 RegisterType; // 0x4
};

struct MODEL_AEX {
    u32 Flags; // 0x0
};

struct MODEL_ALPHA {
    u32 Flags; // 0x0
    padding[3];
    u8 AlphaValue; // 0x7
    u32 InterpParam; // 0x8
    u8 TransparencyMode; // 0xc
};

struct MODEL_ANIM_ADD {
    u32 TrackNo; // 0x0
    s32 AnimNo; // 0x4
    s32 AnimBlendFrame; // 0x8
    f32 AnimWeight; // 0xc
    u32 AnimFlags; // 0x10
    f32 AnimSpeed; // 0x14
    s32 AnimStartFrame; // 0x18
    u32 Flags; // 0x1c
};

struct MODEL_ANIM_BASE {
    s32 Anim1No; // 0x0
    s16 Anim1LoopBlendFrame; // 0x4
    s16 Anim1BlendFrame; // 0x6
    u32 Anim1Flags; // 0x8
    f32 Anim1Speed; // 0xc
    s32 Anim2No; // 0x10
    s16 Anim2LoopBlendFrame; // 0x14
    s16 Anim2BlendFrame; // 0x16
    u32 Anim2Flags; // 0x18
    f32 Anim2Speed; // 0x1c
    u32 Flags; // 0x20
    s32 Anim1StartFrame; // 0x24
    s32 Anim1EndFrame; // 0x28
    s32 Anim2StartFrame; // 0x2c
    s32 Anim2EndFrame; // 0x30
    s32 Anim1WaitFrame; // 0x34
};

struct MODEL_ATTACH {
    u32 Flags; // 0x0
    u32 HelperID; // 0x4
    u32 TargetAssetID; // 0x8
    padding[4];
    vector3 Pos; // 0x10
    euler RotDeg; // 0x1c
    u32 InterpParam; // 0x28
    vector3 DstPos; // 0x2c
    euler DstRotDeg; // 0x38
};

struct MODEL_CLOTH {
    u32 Flags; // 0x0
    s32 IterateCount; // 0x4
};

struct MODEL_CLOTH_ENABLE {
    u32 Flags; // 0x0
    u32 PartFlags; // 0x4
};

struct MODEL_DETACH {
    u32 Flags; // 0x0
    u32 HelperID; // 0x4
    u32 TargetAssetID; // 0x8
    padding[4];
    vector3 Pos; // 0x10
    euler RotDeg; // 0x1c
    u32 InterpParam; // 0x28
    vector3 DstPos; // 0x2c
    euler DstRotDeg; // 0x38
};

struct MODEL_FACIAL_BLEND {
    u32 Flags; // 0x0
    s32 FacialIndex; // 0x4
    s32 BlendFrame; // 0x8
    s32 StartFrame; // 0xc
    s32 RandomSeed; // 0x10
};

struct MODEL_FOOTSTEPS {
    u32 Flags; // 0x0
    s32 FootstepsIndex; // 0x4
};

struct MODEL_ICON {
    u32 Flags; // 0x0
    u32 IconType; // 0x4
    padding[8];
    f32 Scale; // 0x10
    vector3 PosOffset; // 0x14
};

struct MODEL_ICON_TERMINATE {
    u32 Flags; // 0x0
};

struct MODEL_LIPSYNC {
    u32 Flags; // 0x0
    f32 MinInterval; // 0x4
    f32 MaxInterval; // 0x8
    s32 CtrlTypeIndex; // 0xc
};

struct MODEL_LOOKAT {
    u16 Flags; // 0x0
    u16 MotionFlags; // 0x2
    u16 MotionType; // 0x4
    u16 TargetType; // 0x6
    u16 ResetPhysicsCount; // 0x8
    u16 SpeedType; // 0xa
    vector3 TargetPos; // 0xc
    u32 TargetAssetID; // 0x18
    u32 TargetHelperID; // 0x1c
    vector3 HelperOffset; // 0x20
    f32 VerticalAngle; // 0x2c
    f32 HorizontalAngle; // 0x30
};

struct MODEL_MOVE_ANIM {
    u32 Flags; // 0x0
    s32 MoveType; // 0x4
    f32 Speed; // 0x8
    vector3 StartPos; // 0xc
    vector3 TargetPos; // 0x18
    s32 IdleIndex; // 0x24
};

struct PathPoint {
    u32 PathType;
    u32 PointNum;
    vector3 Positions[24];
};


struct MODEL_MOVE_DIRECT {
    PathPoint Path;
    u32 Flags; // 0x128
    f32 Speed; // 0x12c
    s32 MoveFrameLength; // 0x130
    u8 SpeedTypeEarly; // 0x134
    u8 SpeedTypeLate; // 0x135
    padding[2];
    s32 MoveAnimNo; // 0x138
    s32 MoveAnimBlendFrame; // 0x13c
    u32 MoveAnimFlags; // 0x140
    f32 MoveAnimSpeed; // 0x144
    s32 MoveAnimStartFrame; // 0x148
    s32 MoveAnimEndFrame; // 0x14c
    s32 WaitAnimNo; // 0x158
    s32 WaitAnimBlendFrame; // 0x15c
    u32 WaitAnimFlags; // 0x160
    f32 WaitAnimSpeed; // 0x164
    s32 WaitAnimStartFrame; // 0x168
    s32 WaitAnimEndFrame; // 0x16c
};

struct MODEL_MOVE_START_ANIM {
    u32 Flags; // 0x0
    s32 MoveType; // 0x4
    f32 Speed; // 0x8
    vector3 Pos; // 0xc
    s32 Count; // 0x18
    f32 Height; // 0x1c
    f32 Rotation; // 0x20
    s32 IdleIndex; // 0x24
};

struct MODEL_OBJ_DISP {
    u32 Flags; // 0x0
    u32 VisibleFlags; // 0x4
};

struct MODEL_PLANE_GRADATION {
    u32 Flags; // 0x0
    vector3 PlanePos; // 0x4
    f32 PlaneDistance; // 0x10
    euler PlaneRot; // 0x14
    f32RGB LightColor; // 0x20
    f32RGB ShadowColor; // 0x2c
    f32 Attenuation; // 0x38
    f32 Factor; // 0x3c
};

struct MODEL_REGISTER {
    u32 Flags; // 0x0
    u32 RegisterType; // 0x4
    u32 SceneType; // 0x8
};

struct MODEL_ROTATE {
    u32 Flags; // 0x0
    euler AngleDeg; // 0x4
    u32 InterpParam; // 0x10
    s32 TurnFrame; // 0x14
    padding[8];
    s32 TurnAnimNo; // 0x20
    s32 TurnAnimBlendFrame; // 0x24
    u32 TurnAnimFlags; // 0x28
    f32 TurnAnimSpeed; // 0x2c
    s32 TurnAnimStartFrame; // 0x30
    s32 TurnAnimEndFrame; // 0x34
    padding[8];
    s32 WaitAnimNo; // 0x40
    s32 WaitAnimBlendFrame; // 0x44
    u32 WaitAnimFlags; // 0x48
    f32 WaitAnimSpeed; // 0x4c
    s32 WaitAnimStartFrame; // 0x50
    s32 WaitAnimEndFrame; // 0x54
};

struct MODEL_SCALE {
    u32 Flags; // 0x0
    u32 InterpParam; // 0x4
    f32 Scale; // 0x8
};

struct MODEL_SET_DIRECT {
    vector3 Pos; // 0x0
    euler AngleDeg; // 0xc
    s32 WaitAnimNo; // 0x18
    s32 WaitAnimBlendFrame; // 0x1c
    u16 WaitAnimFlags; // 0x20
    f32 WaitAnimSpeed; // 0x24
    u32 Flags; // 0x28
    s32 WaitAnimStartFrame; // 0x2c
    s32 ResetPhysicsCount; // 0x30
};

struct MODEL_TURN {
    u32 Flags; // 0x0
    f32 Speed; // 0x4
    f32 StartAngle; // 0x8
    f32 TargetAngle; // 0xc
};

struct MOVIE_PLAY {
    u32 Flags; // 0x0
    f32 FadeIn; // 0x4
    f32 FadeOut; // 0x8
};

struct PAD_RUMBLE {
    u32 Flags; // 0x0
    u32 TypeIndex; // 0x4
};

struct PFX_BLUR_RADIAL {
    u32 Flags; // 0x0
    u16 FrameLengthIn; // 0x4
    u16 FrameLengthOut; // 0x6
    u32 InterpParamIn; // 0x8
    u32 InterpParamOut; // 0xc
    vector2 CenterPos; // 0x10
    f32 Power; // 0x18
    f32 FallOff; // 0x1c
    u32 BlendType; // 0x20
    u8RGBA ColorRGBA; // 0x24
};

struct PFX_BLUR_STRAIGHT {
    u32 Flags; // 0x0
    u16 FrameLengthIn; // 0x4
    u16 FrameLengthOut; // 0x6
    u32 InterpParamIn; // 0x8
    u32 InterpParamOut; // 0xc
    f32 Direction; // 0x10
    f32 Power; // 0x14
    u32 BlendType; // 0x18
    u8RGBA ColorRGBA; // 0x1c
};

struct PFX_COLOR_CORRECT {
    u32 Flags; // 0x0
    u16 FrameLengthIn; // 0x4
    u16 FrameLengthOut; // 0x6
    u32 InterpParamIn; // 0x8
    u32 InterpParamOut; // 0xc
    vector2 Pos; // 0x10
    vector2 Dims; // 0x18
    f32 Cyan; // 0x20
    f32 Magenta; // 0x24
    f32 Yellow; // 0x28
    f32 Dodge; // 0x2c
    f32 Burn; // 0x30
    f32 Alpha; // 0x34
    u32 TextureAssetID; // 0x38
};

struct PFX_LENSFLARE {
    u32 TemplateType; // 0x0
    vector3 Pos; // 0x4
    f32 Brightness; // 0x14
    u32 FilterType; // 0x18
    bool FilterVisible; // 0x1c
    bool LightGlowVisible; // 0x1d
    bool TerminateGlowVisible; // 0x1e
    bool ZPickerEnable; // 0x1f
    s32 InterpFrameIn; // 0x20
    s32 InterpFrameOut; // 0x24
    u32 InterpParamIn; // 0x28
    u32 InterpParamOut; // 0x2c
    u32 Flags; // 0x30
    u32 AssetID; // 0x34
    u32 HelperID; // 0x38
// Struct ColorRGBA; // 0xffff80017b7e9eb7
};

struct PFX_MONOTONE {
    u32 Flags; // 0x0
    vector2 Pos; // 0x4
    vector2 Dims; // 0xc
    f32 Alpha; // 0x14
};

struct SCRIPT {
u32 Flags; // 0x0
u32 ScriptFuncNameLength; // 0x4
char ScriptFuncName[0x40][[format("fmt_fixed_length_string")]];
};

struct SOUND {
    u32 Flags; // 0x0
    s32 SoundType; // 0x4
    s32 CtrlType; // 0x8
    s32 PlayerNo; // 0xc
    s32 CueID; // 0x10
    f32 Volume; // 0x14
    f32 FadeOut; // 0x18
};

struct SOUND_AMBIENT {
    u32 Flags; // 0x0
    s32 CtrlType; // 0x4
    f32 FadeDuration; // 0x8
};

struct TEXTURE {
    u32 Flags; // 0x0
    u16 FrameLengthIn; // 0x4
    u16 FrameLengthOut; // 0x6
    u32 InterpParamIn; // 0x8
    u32 InterpParamOut; // 0xc
    vector3 Pos; // 0x10
    vector2 Scale; // 0x1c
    vector2 U; // 0x24
    vector2 V; // 0x2c
    u32 RenderPrio; // 0x34
    u32 BlendType; // 0x38
    u8RGBA ColorRGBA; // 0x3c
};

struct TEX_COLOR_CORRECT {
    u32 Flags; // 0x0
    vector2 Pos; // 0x4
    vector2 Dims; // 0xc
    f32 Cyan; // 0x14
    f32 Magenta; // 0x18
    f32 Yellow; // 0x1c
    f32 Dodge; // 0x20
    f32 Burn; // 0x24
    f32 Alpha; // 0x28
};

struct FIELD_REGISTER {
    u32 Flags; // 0x0
    u32 RegisterType; // 0x4
};


struct WIPE {
    u32 Flags; // 0x0
    s32 Action; // 0x4
    s32 IdIndex; // 0x8
};

struct ENV_CHARA_LIGHT {
    u32 Flags;
    f32 Field04;
    u32 Field08;
    f32 Field0C;
    f32 Field10;
    f32 Field14;
    f32 Field18;
    f32 Field1C;
    f32 Field20;
    u32 Field24[0x20];
    u32 FieldA4;
    f32 FieldA8;
};

struct Command {
    char CommandCode[0x4];
    u16 CommandVersion;
    u16 CommandType;
    u32 AssetID;
    u32 Flags;
    u32 FrameStart;
    u32 FrameLength;
    u32 CommandParamOfs;
    u32 CommandParamSize;
    u32 CondType;
    u32 CondIndex;
    u32 CondValue;
    u32 CondCompType;
    char CondName[0x40][[format("fmt_fixed_length_string")]];
    match (CommandCode) {
        ("CMD_"): CAMERA_MOVE_DIRECT Param @ CommandParamOfs;
        ("CSA_"): CAMERA_SET_ASSET Param @ CommandParamOfs;
        ("CSD_"): CAMERA_SET_DIRECT Param @ CommandParamOfs;
        ("CSF_"): CAMERA_SET_FIELD Param @ CommandParamOfs;
        ("CShk"): CAMERA_SHAKE Param @ CommandParamOfs;
        ("Date"): GAME_DATE Param @ CommandParamOfs;
        ("EAlp"): EFFECT_ALPHA @ CommandParamOfs;
        ("EnBc"): ENV_BGCOLOR @ CommandParamOfs;
        ("EnC_"): ENV_CLOUD Param @ CommandParamOfs;
        ("EnCc"): ENV_CORRECT @ CommandParamOfs;
        ("EnCL"): ENV_CHARA_LIGHT @ CommandParamOfs;
        ("EnDf"): ENV_DOF @ CommandParamOfs;
        ("EnDi"): ENV_DIFFUSION @ CommandParamOfs;
        ("Enef"): ENV_EXPONENTIAL_FOG @ CommandParamOfs;
        ("EnHd"): ENV_HDR @ CommandParamOfs;
        ("EnL0"): ENV_LIGHT_0 @ CommandParamOfs;
        ("EnL1"): ENV_LIGHT_1 @ CommandParamOfs;
        ("EnOl"): ENV_OUTLINE @ CommandParamOfs;
        ("EnPg"): ENV_PLANE_GRADATION @ CommandParamOfs;
        ("EnPh"): ENV_PHYSICS @ CommandParamOfs;
        ("EnSD"): ENV_SKYDOME @ CommandParamOfs;
        ("EnSh"): ENV_SHADOW @ CommandParamOfs;
        ("EnSs"): ENV_SSAO @ CommandParamOfs;
        ("Env_"): ENV_SET @ CommandParamOfs;
        ("ERgs"): EFFECT_REGISTER @ CommandParamOfs;
        ("EScl"): EFFECT_SCALE @ CommandParamOfs;
        ("ESD_"): EFFECT_SET_DIRECT @ CommandParamOfs;
        ("ESH_"): EFFECT_SET_HELPER @ CommandParamOfs;
        ("FAB_"): FIELD_OBJ_ANIM_BASE @ CommandParamOfs;
        ("Fd__"): FADE @ CommandParamOfs;
        ("FFD_"): FIELD_FEATURE_DISP @ CommandParamOfs;
        ("FL__"): FIELD_LIGHTS @ CommandParamOfs;
        ("FMD_"): FIELD_MOB_DISP @ CommandParamOfs;
        ("FMDB"): FIELD_MOB_DISP_BOX @ CommandParamOfs;
        ("FOD_"): FIELD_OBJ_DISP @ CommandParamOfs;
        ("FR__"): FIELD_REGISTER @ CommandParamOfs;
        ("FrJ_"): FRAME_JUMP @ CommandParamOfs;
        ("Frus"): FRAME_UNSKIPPABLE @ CommandParamOfs;
        ("FS__"): FIELD_SET @ CommandParamOfs;
        ("GAn_"): GAME_AREA_NAME @ CommandParamOfs;
        ("GBpu"): GAME_BASE_PARAM_UP @ CommandParamOfs;
        ("GCAP"): GAME_FOLLOWER_RANK_UP @ CommandParamOfs;
        ("GHpu"): GAME_HUMAN_PARAM_UP @ CommandParamOfs;
        ("GI__"): GAME_ITEM @ CommandParamOfs;
        ("GM__"): GAME_MONEY @ CommandParamOfs;
        ("GNe_"): GAME_NAME_ENTRY @ CommandParamOfs;
        ("GPne"): GAME_PLAYER_NAME_ENTRY @ CommandParamOfs;
        ("GQ__"): GAME_QUEST @ CommandParamOfs;
        ("GSm_"): GAME_SORTIE_MAP @ CommandParamOfs;
        ("GTut"): GAME_TUTORIAL @ CommandParamOfs;
        ("MAA_"): MODEL_ANIM_ADD @ CommandParamOfs;
        ("MAB_"): MODEL_ANIM_BASE @ CommandParamOfs;
        ("MAex"): MODEL_AEX @ CommandParamOfs;
        ("MAlp"): MODEL_ALPHA @ CommandParamOfs;
        ("MAt_"): MODEL_ATTACH @ CommandParamOfs;
        ("Mbab"): MOB_ANIM_BASE @ CommandParamOfs;
        ("Mbic"): MOB_ICON @ CommandParamOfs;
        ("Mbla"): MOB_LOOKAT @ CommandParamOfs;
        ("Mbr_"): MOB_REGISTER @ CommandParamOfs;
        ("Mbsd"): MOB_SET_DIRECT @ CommandParamOfs;
        ("MCe_"): MODEL_CLOTH_ENABLE @ CommandParamOfs;
        ("MCPr"): MODEL_CLOTH @ CommandParamOfs;
        ("MDt_"): MODEL_DETACH @ CommandParamOfs;
        ("MFb_"): MODEL_FACIAL_BLEND @ CommandParamOfs;
        ("MFs_"): MODEL_FOOTSTEPS @ CommandParamOfs;
        ("MIc_"): MODEL_ICON @ CommandParamOfs;
        ("MIct"): MODEL_ICON_TERMINATE @ CommandParamOfs;
        ("MLa_"): MODEL_LOOKAT @ CommandParamOfs;
        ("MLs_"): MODEL_LIPSYNC @ CommandParamOfs;
        ("Mma_"): MODEL_MOVE_ANIM @ CommandParamOfs;
        ("MMD_"): MODEL_MOVE_DIRECT @ CommandParamOfs;
        ("Mmsa"): MODEL_MOVE_START_ANIM @ CommandParamOfs;
        ("MOD_"): MODEL_OBJ_DISP @ CommandParamOfs;
        ("MPg_"): MODEL_PLANE_GRADATION @ CommandParamOfs;
        ("MRgs"): MODEL_REGISTER @ CommandParamOfs;
        ("MRot"): MODEL_ROTATE @ CommandParamOfs;
        ("MScl"): MODEL_SCALE @ CommandParamOfs;
        ("MSD_"): MODEL_SET_DIRECT @ CommandParamOfs;
        ("Msg_"): MESSAGE @ CommandParamOfs;
        ("MsgV"): MESSAGE_VOICE @ CommandParamOfs;
        ("mskb"): MASK_BLEND @ CommandParamOfs;
        ("mskl"): MASK_LAYER_BLEND @ CommandParamOfs;
        ("MTr_"): MODEL_TURN @ CommandParamOfs;
        ("MvPl"): MOVIE_PLAY @ CommandParamOfs;
        ("PBRd"): PFX_BLUR_RADIAL @ CommandParamOfs;
        ("PBSt"): PFX_BLUR_STRAIGHT @ CommandParamOfs;
        ("PCc_"): PFX_COLOR_CORRECT @ CommandParamOfs;
        ("PLf_"): PFX_LENSFLARE @ CommandParamOfs;
        ("PMn_"): PFX_MONOTONE @ CommandParamOfs;
        ("PRum"): PAD_RUMBLE @ CommandParamOfs;
        ("Scr_"): SCRIPT @ CommandParamOfs;
        ("Snd_"): SOUND @ CommandParamOfs;
        ("SndA"): SOUND_AMBIENT @ CommandParamOfs;
        ("Subs"): SUBTITLE @ CommandParamOfs;
        ("TCc_"): TEX_COLOR_CORRECT @ CommandParamOfs;
        ("Tex_"): TEXTURE @ CommandParamOfs;
        ("Wp__"): WIPE @ CommandParamOfs;
    }
}[[format("fmt_command")]];//[[name(std::format("{}", CommandCode))]];

fn fmt_command(ref Command self) {
    return std::format("{}: ASSET: {}, FRAME: {}-{}", self.CommandCode, self.AssetID, self.FrameStart, self.FrameStart + self.FrameLength);
};

enum FileType : u8 {
    Evt = 0,
    Ecs = 1,
    Unk = 2
};

fn get_file_type() {
    str ext = std::string::substr(std::string::to_lower(hex::prv::get_information("file_extension")), 1, 3);
    match (ext) {
        ("evt"): return FileType::Evt;
        ("ecs"): return FileType::Ecs;
        (_): return FileType::Unk;
    }
};

struct Evt {
    FileType file = get_file_type();
    match (file) {
        (FileType::Evt): EvtHeader header;
        (FileType::Ecs): EcsHeader header;
    }
    std::assert(file != FileType::Unk, "Unsupported filetype for this template");
    if (file == FileType::Evt) {
        Object object[header.AssetNums];
    }
    Command commands[header.CommandNums];
    if (file == FileType::Evt) {
        if (header.MessagePathOfs > 0) {
            char MessagePath[header.MessagePathSize] @ header.MessagePathOfs[[format("fmt_fixed_length_string")]];
        }
        if (header.ScriptPathOfs > 0) {
            char ScriptPath[header.ScriptPathSize] @ header.ScriptPathOfs[[format("fmt_fixed_length_string")]];
        }
    }
};

Evt evt @ 0x00[[inline]];