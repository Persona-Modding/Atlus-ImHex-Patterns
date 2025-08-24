#pragma author SecreC.
#pragma description Loads files relating to P5R Minimaps

// Includes
#include <std/mem.pat>
#include <std/string.pat>
#include <hex/provider.pat>

// common includes
#include <p5r/common/bitflag.expat>
#include <p5r/common/numerics.expat>

// Roadmap structs
#include <p5r/roadmap/structs/roadmap.expat>
#include <p5r/roadmap/structs/texpack.expat>
#include <p5r/roadmap/structs/texelem.expat>
#include <p5r/roadmap/structs/texlist.expat>
#include <p5r/roadmap/structs/roadmapParams.expat>

// Globals
str fileName = hex::prv::get_information("file_name");
u32 fileSize = std::mem::size();
u32 layer = 0;

struct RoadmapFile {
    match (std::string::to_lower(fileName)) {
        ("roadmap.bin") : roadmapBin roadmap;
        ("texpack.bin") : texpackBin texpack;
        ("texelem.bin") : texelemBin texelem;
        ("texlist.bin") : texlistBin texlist;
        (_) : roadmapParamBin mapParams;
    }
}[[inline]];

RoadmapFile file @0x00;
