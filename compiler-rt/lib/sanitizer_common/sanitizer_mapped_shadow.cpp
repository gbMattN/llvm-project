

#include "sanitizer_common/sanitizer_common.h"
#include "sanitizer_common/sanitizer_mapped_shadow.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>

Mapped_Shadow_Mem msm;

void* Mapped_Shadow_Mem::operator[](uptr address){
  //#error "Why"
    if(!hasSetup){
      return nullptr;
    }
    //__sanitizer::Printf("MSM [%p]\n", (void*)address);
    uptr key = keyFromAddress(address);
    uptr subaddress = address & CHUNK_MASK;
    
    //__sanitizer::Printf("MSM [%p], key is %p, subaddress is %p\n", (void*)address, (void*)key, (void*)subaddress);

    Node* currentNode = firstNode;
    while(currentNode){
      if(currentNode->key == key){
        return (void*)(currentNode->mmRegion + subaddress);
      }
      
      if(key < currentNode->key){
        currentNode = currentNode->nextNode;
      }
      // Greater
      else{
        Node* newNode = &freeNodes[nextFreeNode];
        nextFreeNode += 1;
        createNode(key, newNode);
        newNode->previousNode = currentNode->previousNode;
        newNode->previousNode->nextNode = newNode;
        newNode->nextNode = currentNode;
        currentNode->previousNode = newNode;
        return (void*)(newNode->mmRegion + subaddress);
      }
    }

    Node* newNode = &freeNodes[nextFreeNode];
    nextFreeNode += 1;
    createNode(key, newNode);
    lastNode->nextNode = newNode;
    newNode->previousNode = lastNode;
    lastNode = newNode;

    return (void*)(newNode->mmRegion + subaddress);
}

bool Mapped_Shadow_Mem::isMapped(uptr address){
    if(!hasSetup){
      return false;
    }
    //__sanitizer::Printf("MSM [%p]\n", (void*)address);
    uptr key = keyFromAddress(address);
    
    //__sanitizer::Printf("MSM [%p], key is %p, subaddress is %p\n", (void*)address, (void*)key, (void*)subaddress);

    Node* currentNode = firstNode;
    while(currentNode){
      if(currentNode->key == key){
        return true;
      }
      
      if(key < currentNode->key){
        currentNode = currentNode->nextNode;
      }
      // Greater
      else{
        return false;
      }
    }

    return false;
}

Mapped_Shadow_Mem::Mapped_Shadow_Mem(){
    __sanitizer::Printf("MAPPED_SHADOW_MEM CONSTRUCTOR BEGIN\n");
    nextFreeNode = 1;
    firstNode = lastNode = &freeNodes[0];
    char onStack = 0;
    createNode(keyFromAddress((uptr)&onStack), firstNode);
    firstNode->nextNode = firstNode->previousNode = nullptr;

    hasSetup = true;
    __sanitizer::Printf("MAPPED_SHADOW_MEM CONSTRUCTOR END\n");
}

inline uptr Mapped_Shadow_Mem::keyFromAddress(uptr address){
    return ((address & ~CHUNK_MASK) >> CHUNK_SHIFT) & CHUNK_MASK;
}

void Mapped_Shadow_Mem::createNode(uptr key, Node* node){
    //__sanitizer::Printf("  MSM Create Node Key %p\n", (void*)key);
    char filename[256];
    sprintf(filename, "shadow_filename_%lx.bin", key);
    int fileDescriptor = open(filename, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
    if(fileDescriptor == -1){
        int errsv = errno;
        __sanitizer::Printf("ERROR: fd is bad: %d\n", errsv);
    }
    ftruncate(fileDescriptor, CHUNK_MASK);

    node->fileDescriptor = fileDescriptor;
    node->key = key;
    node->mmRegion = (uptr)mmap64(
        (void*)(key << CHUNK_SHIFT), 
        CHUNK_MASK, 
        PROT_READ | PROT_WRITE, 
        MAP_PRIVATE,
        fileDescriptor, 
        0
    );

    if((void*)node->mmRegion == (void*)-1){
        int errsv = errno;
        __sanitizer::Printf("ERROR: err is %d\n", errsv);
    }
    else if((void*)node->mmRegion == MAP_FAILED){
        int errsv = errno;
        __sanitizer::Printf("ERROR: err is %d\n", errsv);
    }
    //else __sanitizer::Printf("  MSM Create Node region has been mapped to %p\n", (void*)node->mmRegion);

    node->nextNode = node->previousNode = nullptr;
}
