//===-- tysan.h -------------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file is a part of TypeSanitizer.
//
// Private TySan header.
//===----------------------------------------------------------------------===//

#ifndef TYSAN_H
#define TYSAN_H

#include "sanitizer_common/sanitizer_common.h"
#include "sanitizer_common/sanitizer_internal_defs.h"

using __sanitizer::sptr;
using __sanitizer::u16;
using __sanitizer::uptr;

#include "tysan_platform.h"

#include <unistd.h>
#include <fcntl.h>

extern "C" {
void tysan_set_type_unknown(const void *addr, uptr size);
void tysan_copy_types(const void *daddr, const void *saddr, uptr size);
}

namespace __tysan {
extern bool tysan_inited;
extern bool tysan_init_is_running;

void InitializeInterceptors();

enum { TYSAN_MEMBER_TD = 1, TYSAN_STRUCT_TD = 2 };

struct tysan_member_type_descriptor {
  struct tysan_type_descriptor *Base;
  struct tysan_type_descriptor *Access;
  uptr Offset;
};

struct tysan_struct_type_descriptor {
  uptr MemberCount;
  struct {
    struct tysan_type_descriptor *Type;
    uptr Offset;
  } Members[1]; // Tail allocated.
};

struct tysan_type_descriptor {
  uptr Tag;
  union {
    tysan_member_type_descriptor Member;
    tysan_struct_type_descriptor Struct;
  };
};

// About 256 MB
#define CHUNK_MASK 0xfffffff
#define CHUNK_SHIFT 28
class Mapped_Shadow_Mem{
public:

  void* operator[](uptr address){
    if(!hasSetup){
      __sanitizer::Printf("  Setup isn't complete\n");
      return nullptr;
    }
    uptr key = keyFromAddress(address);
    uptr subaddress = address & CHUNK_MASK;

    __sanitizer::Printf("  Accessing map with Key %lx and subaddress %lu\n", key, subaddress);

    Node* currentNode = firstNode;
    while(currentNode){
      __sanitizer::Printf("  Checking Node with Key %lx\n", currentNode->key);
      if(currentNode->key == key)
        return currentNode->mmRegion[subaddress];
      
      if(key < currentNode->key)
        currentNode = currentNode->nextNode;
      // Greater
      else{
        __sanitizer::Printf("    Inserting a Node between two others\n");
        Node* newNode = &freeNodes[nextFreeNode];
        nextFreeNode += 1;
        createNode(key, newNode);
        newNode->previousNode = currentNode->previousNode;
        newNode->previousNode->nextNode = newNode;
        newNode->nextNode = currentNode;
        currentNode->previousNode = newNode;
        return newNode->mmRegion[subaddress];
      }
    }

    __sanitizer::Printf("    Adding a new Node to the end\n");
    Node* newNode = &freeNodes[nextFreeNode];
    nextFreeNode += 1;
    createNode(key, newNode);
    lastNode->nextNode = newNode;
    newNode->previousNode = lastNode;
    lastNode = newNode;

    return newNode->mmRegion[subaddress];
  }

  Mapped_Shadow_Mem(){
    __sanitizer::Printf("Creating shadow Mem\n");
    nextFreeNode = 1;
    firstNode = lastNode = &freeNodes[0];
    char onStack = 0;
    createNode(keyFromAddress((uptr)&onStack), firstNode);
    firstNode->nextNode = firstNode->previousNode = nullptr;

    hasSetup = true;
  }

private:
  struct Node{
    int fileDescriptor;
    void** mmRegion;
    // When you mask and shift the address, this is what you get
    uptr key;
    Node* nextNode;
    Node* previousNode;
  };

  void createNode(uptr key, Node* node);

  inline uptr keyFromAddress(uptr address){
    return ((address & ~CHUNK_MASK) >> CHUNK_SHIFT) & CHUNK_MASK;
  }

  bool hasSetup;
  Node* firstNode, *lastNode;
  Node freeNodes[256];
  unsigned nextFreeNode;
};
extern Mapped_Shadow_Mem msm;

inline tysan_type_descriptor **shadow_for(const void *ptr) {
  // auto* requestedAddress = (tysan_type_descriptor **)((((uptr)ptr) & AppMask()) * sizeof(ptr) +
  //                                   ShadowAddr());
  // msm[(uptr)(requestedAddress - ShadowAddr())];
  // return requestedAddress;
  __sanitizer::Printf("Getting shadow for memory\n");
  auto maskedAddr = (((uptr)ptr) & AppMask()) * sizeof(ptr);
  if(void* address = msm[maskedAddr])
    return (tysan_type_descriptor **)address;
  // Drop back
  __sanitizer::Printf("  Dropping back to regular shadow memory\n");
  return (tysan_type_descriptor **)maskedAddr + ShadowAddr();
}

struct Flags {
#define TYSAN_FLAG(Type, Name, DefaultValue, Description) Type Name;
#include "tysan_flags.inc"
#undef TYSAN_FLAG

  void SetDefaults();
};

extern Flags flags_data;
inline Flags &flags() { return flags_data; }

} // namespace __tysan

#endif // TYSAN_H
