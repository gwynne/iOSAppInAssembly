// main_ARMv7.s
// This is the entry point of the application, in ARMv7 assembly.

// Firstly, we will setup all strings that will be used for the first part of this app.
// Then, we will setup an auto-release pool to manage our dangling objects,
// And finally, we will jump right into UIApplicationMain.

// Create a raw C string to hold the data for the App Delegate class name
	.section __TEXT,__cstring,cstring_literals
l_.delegateClassNameCStr:
    .asciz "AppDelegate"

// Create an CFString/NSString wrapper around the C string
	.section __DATA,__cfstring
L_delegateClassNameString:
	.align 2
	// isa
	.long ___CFConstantStringClassReference
	// cfinfo
	.long 1992
	// buffer
	.long l_.delegateClassNameCStr
	// length
	.long 11

//
// Entry point of the application.
//
// Parameters:
//   None.
//
// Results:
//   r0: error code to return to OS.
//
// 
.section __TEXT,__text,regular,pure_instructions
.global _main
.align 2
_main:
	// Set up a frame pointer and save any non-volatile (callee-saved) registers used by the function.
    push     {r4-r7, lr}           // save LR, R7, R4-R6
    add      r7, sp, #12           // adjust R7 to point to saved R7

	// Save off argc and argv (r0 and r1), we need them later and r0 and r1 can be clobbered in subroutines
	mov		 r4, r0
	mov		 r5, r1

    // Push an autorelease pool. This is done using the internal function objc_autoreleasePoolPush.
    // It takes no parameters and returns no results.
    blx _objc_autoreleasePoolPush

	// Setup our app delegate's class.
    // It takes no parameters and returns no results.
    blx AppDelegate_Setup

    // Setup our custom view's class.
    // It takes no parameters and returns no results.
    blx View_Setup

	// Call UIApplicationMain.
	// It takes four parameters (main's argc and argv, a nib name, and a delegte class name), and returns
	//	the value main should return.
	// This sequence loads a PC-relative value into r3
	movw r3, :lower16:(L_delegateClassNameString-(l_.stringLoad+8))
	movt r3, :upper16:(L_delegateClassNameString-(l_.stringLoad+8))
l_.stringLoad:
	add r3, pc

	mov r0, r4
	mov r1, r5
	mov r2, #0
	blx _UIApplicationMain
	mov r4, r0 // save off the return value

	// Pop the autorelease pool using the internal function objc_autoreleasePoolPop.
	// It takes no parameters, and returns no useful value.
	blx _objc_autoreleasePoolPop

	// reload the UIApplicationMain return value
	mov r0, r4

	// Tear down frame pointer
    pop      {r4-r7, pc}           // restore R4-R6, saved R7, return to saved LR
