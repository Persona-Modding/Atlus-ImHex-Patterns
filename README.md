# Atlus-ImHex-Patterns
A repository for [ImHex](https://github.com/WerWolv/ImHex) patterns for files from Atlus games.

## Using Patterns
In the future, if this repository gets some traction, it should be added to the official [ImHex Patterns Repo](https://github.com/WerWolv/ImHex-Patterns) so patterns can be downloaded directly from the app. For now, I don't think it's worth doing this.

So, to use these patterns clone this repo. When doing so you should put this into a directory named `patterns/atlus` (e.g. `E:\Github\ImHexPatterns\patterns\atlus`). 
Then in ImHex go to Extras->Settings->Folders and add the folder *above* the `patterns` folder (e.g. `E:\Github\ImHexPatterns`) to the list of folders that ImHex searches through. 

<img width="703" height="407" alt="image" src="https://github.com/user-attachments/assets/27801e44-fa92-45bc-8314-1372d6bf2170" />

Now, in the pattern editor window you can right click -> *Import pattern file* to import one of the files from this repo.

## Writing Patterns
Check out ImHex's [pattern language documentation](https://docs.werwolv.net/pattern-language/) to see how to write patterns. 

When writing patterns for this repo you can import other patterns from it under the `atlus` folder. For example, the FTD template under `common/ftd.hexpat` is a generic template that you could import and use like:

```
#include <atlus/common/ftd.hexpat>

struct Message {
    char Text[64];
};

Ftd<Message> File @ 0 [[inline]];
```

Note that the reason you need to put files in the specific directory structure is so you can import from `atlus/...` like this! When this is all put in the official pattern repo we will try to put everything under that same path.
