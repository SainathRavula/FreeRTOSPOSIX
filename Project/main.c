/*
    FreeRTOS V9.0.0 - Copyright (C) 2016 Real Time Engineers Ltd.
    All rights reserved

    VISIT http://www.FreeRTOS.org TO ENSURE YOU ARE USING THE LATEST VERSION.

    This file is part of the FreeRTOS distribution.

    FreeRTOS is free software; you can redistribute it and/or modify it under
    the terms of the GNU General Public License (version 2) as published by the
    Free Software Foundation >>>> AND MODIFIED BY <<<< the FreeRTOS exception.

    ***************************************************************************
    >>!   NOTE: The modification to the GPL is included to allow you to     !<<
    >>!   distribute a combined work that includes FreeRTOS without being   !<<
    >>!   obliged to provide the source code for proprietary components     !<<
    >>!   outside of the FreeRTOS kernel.                                   !<<
    ***************************************************************************

    FreeRTOS is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
    FOR A PARTICULAR PURPOSE.  Full license text is available on the following
    link: http://www.freertos.org/a00114.html

    ***************************************************************************
     *                                                                       *
     *    FreeRTOS provides completely free yet professionally developed,    *
     *    robust, strictly quality controlled, supported, and cross          *
     *    platform software that is more than just the market leader, it     *
     *    is the industry's de facto standard.                               *
     *                                                                       *
     *    Help yourself get started quickly while simultaneously helping     *
     *    to support the FreeRTOS project by purchasing a FreeRTOS           *
     *    tutorial book, reference manual, or both:                          *
     *    http://www.FreeRTOS.org/Documentation                              *
     *                                                                       *
    ***************************************************************************

    http://www.FreeRTOS.org/FAQHelp.html - Having a problem?  Start by reading
    the FAQ page "My application does not run, what could be wrong?".  Have you
    defined configASSERT()?

    http://www.FreeRTOS.org/support - In return for receiving this top quality
    embedded software for free we request you assist our global community by
    participating in the support forum.

    http://www.FreeRTOS.org/training - Investing in training allows your team to
    be as productive as possible as early as possible.  Now you can receive
    FreeRTOS training directly from Richard Barry, CEO of Real Time Engineers
    Ltd, and the world's leading authority on the world's leading RTOS.

    http://www.FreeRTOS.org/plus - A selection of FreeRTOS ecosystem products,
    including FreeRTOS+Trace - an indispensable productivity tool, a DOS
    compatible FAT file system, and our tiny thread aware UDP/IP stack.

    http://www.FreeRTOS.org/labs - Where new FreeRTOS products go to incubate.
    Come and try FreeRTOS+TCP, our new open source TCP/IP stack for FreeRTOS.

    http://www.OpenRTOS.com - Real Time Engineers ltd. license FreeRTOS to High
    Integrity Systems ltd. to sell under the OpenRTOS brand.  Low cost OpenRTOS
    licenses offer ticketed support, indemnification and commercial middleware.

    http://www.SafeRTOS.com - High Integrity Systems also provide a safety
    engineered and independently SIL3 certified version for use in safety and
    mission critical applications that require provable dependability.

    1 tab == 4 spaces!
*/

/*
 * main() creates all the demo application tasks, then starts the scheduler.
 * The web documentation provides more details of the standard demo application
 * tasks, which provide no particular functionality but do provide a good
 * example of how to use the FreeRTOS API.
 *
 * In addition to the standard demo tasks, the following tasks and tests are
 * defined and/or created within this file:
 *
 * "Check" task - This only executes every five seconds but has a high priority
 * to ensure it gets processor time.  Its main function is to check that all the
 * standard demo tasks are still operational.  While no errors have been
 * discovered the check task will print out "OK" and the current simulated tick
 * time.  If an error is discovered in the execution of a task then the check
 * task will print out an appropriate error message.
 *
 */


/* Standard includes. */
#include <stdio.h>
#include <stdlib.h>
#include "FreeRTOS.h"		
#include "task.h"
#include "timers.h"
#include "queue.h"


void vApplicationIdleHook(void);
static void vSenderTask(void *pvParameters);
static void vReceiverTask(void *pvParameters);

QueueHandle_t xQueue;
int main ( void )
{
	char *ptr;
	printf("size = %d\n",sizeof(ptr));
	xQueue = xQueueCreate(5,sizeof(int32_t));
	if(xQueue != NULL) 
	{
		xTaskCreate(vSenderTask,"Sender 1",1000,(void*)100,1,NULL);
		xTaskCreate(vSenderTask,"Sender 2",1000,(void*)200,2,NULL);
		xTaskCreate(vReceiverTask,"Receiver",1000,NULL,3,NULL);
		vTaskStartScheduler();
	}
	else 
	{
		printf("Could not create Queue\n");
	}
	for(;;);
}
static void vSenderTask(void *pvParameters) 
{
	int32_t lvalueToSend;
	BaseType_t xStatus;
	lvalueToSend = (int32_t) pvParameters;
	
	for(;;) 
	{ 
		printf("In Sending Task,Sending value:%d\n",lvalueToSend);
		xStatus = xQueueSendToBack(xQueue,&lvalueToSend,0);
		vTaskDelay(10);
		if(xStatus != pdPASS)
		{
			printf("Could not send to the queue %d.\n",lvalueToSend);
			
		}
	}
}
static void vReceiverTask(void *pvParameters) 
{
	int32_t lReceivedValue;
	BaseType_t xStatus;
	(void)pvParameters;
	//const TickType_t xTicksToWait = pdMS_TO_TICKS(0.5);
	for(;;)
	{
		if(uxQueueMessagesWaiting(xQueue) != 0)
		{
			printf("Queue should have been empty!\n");
		}
		xStatus = xQueueReceive(xQueue,&lReceivedValue,portMAX_DELAY);
		if(xStatus == pdPASS) 
		{
			printf("Received Value= %d\n",lReceivedValue);
			
		}
		else
		{
			printf("Could not recieve from the queue.\n");
		}
	}
	
}
void vAssertCalled( unsigned long ulLine, const char * const pcFileName )
{

        printf("[ASSERT] %s:%lu\n", pcFileName, ulLine);
        fflush(stdout);
	exit(-1);
}

void vApplicationIdleHook(void)
{
/*************************************************************/
//Uncomment below code to test the vAssertCalled function
//The idle hook fucntion should not use blocking API like vTaskDelay so it assertion fails here
	//volatile int32_t x;
	//printf("Idle\r\n");
	//vTaskDelay(100);
	//for(x = 0;x < 100000000 ; x++);
/*************************************************************/
	
}

