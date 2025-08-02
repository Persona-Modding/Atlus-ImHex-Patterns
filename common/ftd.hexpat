struct Ftd<T> {
    u32 FileSize;
    u32 NumEntries;
    padding[8];
    T Entries[NumEntries];
};