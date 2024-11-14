# Dragon12 Board (MC9S12DP256 controller)


[![GitHub](https://img.shields.io/badge/--181717?logo=github&logoColor=ffffff)](https://github.com/)
[brown9804](https://github.com/brown9804)

Last updated: 2021-01-14

------------------------------------------

<div align="center">
  <h3 style="color: #4CAF50;">Total Visitors</h3>
  <img src="https://profile-counter.glitch.me/brown9804/count.svg" alt="Visitor Count" style="border: 2px solid #4CAF50; border-radius: 5px; padding: 5px;"/>
</div>

> Here you can find design/simulations of different projects using a Dragon 12 board.

![alt text](https://github.com/brown9804/Dragon12_MC9S12DP256/blob/main/8_runmeter623/docs/base_ref/Dragon12%2B_front.png?raw=true)

## Dependencies
Need to install the simulator and some driver, inside "dependencies" folder is explained how to install.

## Projects:
### 0. env_std_tester [Assembly]
This folder contains the standard test files for the  Dragon 12 board.

### 1. ep_AppDev [Assembly]
This work analyzes what are embedded processors, 
ISA Architecture, internal processor design, 
application development, ISA 9S12 Model, etc.

### 2. math_ISA_9S12 [Assembly]
This folder contains three different algorith to understand 
program design and development tools and 9S12 ISA model (math operations).

### 3. sqrt_program [Assembly]
This folder contains a sqrt calculator to understand 
modular programming structures, specifically subroutines.

### 4. mtx_KeyBoard [Assembly]
Contains 9S12 Peripherals: Input / Output structures: parallel ports,
clock and Exceptions system, the timer module. 

### 5. mux_Screens [Assembly]
This project works with the Input Capture: pulse accumulator,
screen management (multiplexed screens, self-contained screens)
and the Analog Digital Conversion Module: A / D converters operation,
types of A / D converters, 9S12 A / D converters, ATD records, A / D 
conversion example, ATD external trigger, and ATD port as digital inputs. 

### 6. asyn_commun [Assembly]
This work encompasses the Asynchronous Serial communication application. 
SCI Interface: concepts of serial communication, the Serial Communication Interface 
(SCI), configuration of the SCI Interface and operation of the SCI Interface.

### 7. syncr_commu [MarkDown]
Synchronous serial communication:

1.Principle of the operation of synchronous communication.


2.Serial Port Interface (SPI): SPI hardware interface, 9S12 SPI interface, S12 SPI interface configuration, Bidirectional Mode configuration, the LTC1661, sawtooth generator.


3.IIC Interface: Inter Bus hardware interface, Inter Bus protocol, IIC interface configuration of 9S12, RTC DS1207.

### 8. runmeter623 [Assembly]
A system is implemented for the display of information in a velodrome. The system, called RunMeter 623, has two photoreflective presence sensors, a 4-digit 7-segment display and a 2x16 LCD display. In this figure it can be seen that the system has two photoreflective presence sensors to detect the bicycles, 55 meters apart and a screen, located 300 meters from the S2 sensor, to present the speed of the bicycle calculated in Km / h and the number of laps traveled.

The sensors emit an infrared signal across the track to a receiver on the other side of the track. When a cyclist passes, the beam is interrupted at the first sensor and a signal is sent to the controller. When the first sensor is passed, the count of the time required by the cyclist to reach the second sensor begins. With this time and with the distance between the sensors, a calculation is made of the cyclist's average speed, in km / h. This speed is presented to the rider on the screen.

