
#ifndef SMS
#define SMS

#include "sanitizer_common/sanitizer_internal_defs.h"
using __sanitizer::uptr;

// About 256 MB
#define CHUNK_MASK 0xfffffff
#define CHUNK_SHIFT 28
class Mapped_Shadow_Mem{
public:

  void* operator[](uptr address);

  bool isMapped(uptr address);

  Mapped_Shadow_Mem();

private:
  struct Node{
    int fileDescriptor;
    uptr mmRegion;
    // When you mask and shift the address, this is what you get
    uptr key;
    Node* nextNode;
    Node* previousNode;
  };

  void createNode(uptr key, Node* node);

  inline uptr keyFromAddress(uptr address);

  bool hasSetup;
  Node* firstNode, *lastNode;
  Node freeNodes[256];
  unsigned nextFreeNode;
};
extern Mapped_Shadow_Mem msm;

#endif
