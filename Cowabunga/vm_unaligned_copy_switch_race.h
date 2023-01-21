#include <stdio.h>
#include <mach/mach.h>
@import Foundation;
#define ROUND_DOWN_PAGE(val) (val & ~(PAGE_SIZE - 1ULL))

// missing prototypes:

kern_return_t mach_vm_allocate
 (
  vm_map_t target,
  mach_vm_address_t *address,
  mach_vm_size_t size,
  int flags
  );

kern_return_t mach_vm_deallocate
 (
  vm_map_t target,
  mach_vm_address_t address,
  mach_vm_size_t size
  );

kern_return_t mach_vm_read_overwrite
 (
  vm_map_read_t target_task,
  mach_vm_address_t address,
  mach_vm_size_t size,
  mach_vm_address_t data,
  mach_vm_size_t *outsize
  );

kern_return_t mach_vm_map
 (
  vm_map_t target_task,
  mach_vm_address_t *address,
  mach_vm_size_t size,
  mach_vm_offset_t mask,
  int flags,
  mem_entry_name_port_t object,
  memory_object_offset_t offset,
  boolean_t copy,
  vm_prot_t cur_protection,
  vm_prot_t max_protection,
  vm_inherit_t inheritance
  );

kern_return_t mach_vm_protect
(
        vm_map_t target_task,
        mach_vm_address_t address,
        mach_vm_size_t size,
        boolean_t set_maximum,
        vm_prot_t new_protection
);

void overwriteFile(NSData *data, NSString *path);
