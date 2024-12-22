#include <SPI.h>
#include <MFRC522.h>
#include "ArduinoJson.h"
#include "pitches.h"

#define BUZZZER_PIN     19
#define RST_PIN         9           // Configurable, see typical pin layout above
#define SS_PIN          10          // Configurable, see typical pin layout above

#include <stdio.h>
char sprintbuff[100];
#define PRINTF(...) {sprintf(sprintbuff,__VA_ARGS__);Serial.print(sprintbuff);}

MFRC522 mfrc522(SS_PIN, RST_PIN);   // Create MFRC522 instance.

MFRC522::MIFARE_Key key;

int maxSize = 0x10 * 3 * 16;
byte dataSize[2]{};
byte dataBuf[0x10 * 3 * 16 + 16]{};
bool toReadData = false;
bool toWriteData = false;
bool toWipeData = false;
int dataSizeByteSize = 2;
int offset = 0;
char defaultData[160] = "{\"NM\":\"\",\"DOB\":\"\",\"SEX\":\"\",\"CON\":\"\",\"EMC\":\"\",\"CI\":[],\"PH\":[],\"AL\":[],\"FMH\":[],\"VR\":[],\"DOA\":[],\"BR\":[],\"LTR\":[],\"AH\":[],\"MH\":[]}";
char testData[720] = "{\"NM\":\"John Doe\",\"DOB\":\"1985-06-15\",\"SEX\":\"Male\",\"CON\":\"+1234567890\",\"ECON\":\"+0987654321\",\"CI\":[\"Diabetes\",\"Hypertension\"],\"PH\":[\"Appendectomy (2010)\",\"Knee surgery (2015)\"],\"AL\":[\"Penicillin\",\"Peanuts\"],\"FMH\":[\"Father: Heart disease\",\"Mother: Cancer\"],\"VR\":[{\"va\":\"COVID-19\",\"doa\":\"2021-03-15\",\"bo\":false},{\"va\":\"Influenza\",\"doa\":\"2023-10-05\",\"bo\":true}],\"DOA\":[\"2023-12-01\"],\"BR\":[\"2023-12-05\"],\"LTR\":[{\"te\":\"Blood test\",\"d\":\"2023-11-15\",\"r\":\"Normal\"},{\"te\":\"X-ray\",\"d\":\"2023-11-10\",\"r\":\"Fracture detected\"}],\"AH\":[{\"ad\":\"2023-12-01\",\"r\":\"Routine checkup\"},{\"ad\":\"2023-11-15\",\"r\":\"Follow-up after surgery\"}],\"MH\":[{\"m\":\"Metformin\",\"d\":\"500mg\",\"f\":\"Twice a day\"},{\"m\":\"Amlodipine\",\"d\":\"10mg\",\"f\":\"Once a day\"}]}";
bool rfid_tag_present_prev = false;
bool rfid_tag_present = false;
int _rfid_error_counter = 0;
bool _tag_found = false;

StaticJsonDocument<1000> doc;

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID        "4fafc201-1fb5-459e-8fcc-c5c9c331914b"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"
BLEServer *pServer;
BLEService *pService;
BLECharacteristic *pCharacteristic;
class MyCallbacks: public BLECharacteristicCallbacks {
  void onRead(BLECharacteristic* pCharacteristic) {
    Serial.println("Characteristic was read.");
    char buffer[20]{};
    if (offset < strlen((char*)dataBuf)+1) {
      memcpy(buffer, dataBuf + offset, 16);
      offset += 16;
      pCharacteristic->setValue(buffer);
      pCharacteristic->notify();
      // You can also access the value of the characteristic here if needed
      PRINTF("Current Value: %s\n", (pCharacteristic->getValue()).c_str());
    }
  }

  void onWrite(BLECharacteristic* pCharacteristic) {
    Serial.println("Characteristic was written.");
    if(strcmp((pCharacteristic->getValue()).c_str(), "") != 0)
    {
      PRINTF("Read byte %2x\n", (uint)pCharacteristic->getValue()[0]);
      if (pCharacteristic->getValue()[0] == 0x11) {
        toReadData = true;
        toWriteData = false;
        toWipeData = false;
      } else if (pCharacteristic->getValue()[0] == 0x12) {
        toReadData = false;
        toWriteData = true;
        toWipeData = false;
      } else if (pCharacteristic->getValue()[0] == 0x80) {
        toReadData = false;
        toWriteData = false;
        toWipeData = true;
      }
      Serial.println((pCharacteristic->getValue()).c_str());
    }
  }
};

void BLESetup() {
  BLEDevice::init("ID Scanner");
  pServer = BLEDevice::createServer();
  pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                                        CHARACTERISTIC_UUID,
                                        BLECharacteristic::PROPERTY_READ |
                                        BLECharacteristic::PROPERTY_WRITE
                                      );
  pCharacteristic->setCallbacks(new MyCallbacks());
  pService->start();
  BLEAdvertising *pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
}

void setup() {
    Serial.begin(9600); // Initialize serial communications with the PC
    while (!Serial);    // Do nothing if no serial port is opened (added for Arduinos based on ATMEGA32U4)
    SPI.begin();        // Init SPI bus
    mfrc522.PCD_Init(); // Init MFRC522 card

    // Prepare the key (used both as key A and as key B)
    // using FFFFFFFFFFFFh which is the default at chip delivery from the factory
    for (byte i = 0; i < 6; i++) {
        key.keyByte[i] = 0xFF;
    }

    BLESetup();
}

void loop() {
    if (toReadData || toWriteData) {
      if ( ! mfrc522.PICC_IsNewCardPresent()) return;
      if ( ! mfrc522.PICC_ReadCardSerial()) return;
      tone(BUZZZER_PIN, NOTE_C4, 1000/4);
      delay(4 * 1.30);
      noTone(BUZZZER_PIN);

      MFRC522::PICC_Type piccType = mfrc522.PICC_GetType(mfrc522.uid.sak);
      // Check for compatibility
      if (    piccType != MFRC522::PICC_TYPE_MIFARE_MINI
          &&  piccType != MFRC522::PICC_TYPE_MIFARE_1K
          &&  piccType != MFRC522::PICC_TYPE_MIFARE_4K) {
          Serial.println(F("This sample only works with MIFARE Classic cards."));
          return;
      }
      // wipeData();

      // while (true) {
        // readAllData();

        // rfid_tag_present_prev = rfid_tag_present;

        // _rfid_error_counter += 1;
        // if(_rfid_error_counter > 2){
        //   _tag_found = false;
        // }

        // // Detect Tag without looking for collisions
        // byte bufferATQA[2];
        // byte bufferSize = sizeof(bufferATQA);

        // // Reset baud rates
        // mfrc522.PCD_WriteRegister(mfrc522.TxModeReg, 0x00);
        // mfrc522.PCD_WriteRegister(mfrc522.RxModeReg, 0x00);
        // // Reset ModWidthReg
        // mfrc522.PCD_WriteRegister(mfrc522.ModWidthReg, 0x26);

        // MFRC522::StatusCode result = mfrc522.PICC_RequestA(bufferATQA, &bufferSize);

        // if(result == mfrc522.STATUS_OK){
        //   if ( ! mfrc522.PICC_ReadCardSerial()) { //Since a PICC placed get Serial and continue   
        //     return;
        //   }
        //   _rfid_error_counter = 0;
        //   _tag_found = true;        
        // }
        
        // rfid_tag_present = _tag_found;
        
        // // rising edge
        // if (rfid_tag_present && !rfid_tag_present_prev){
        //   Serial.println("Tag found");
        // }
        
        // // falling edge
        // if (!rfid_tag_present && rfid_tag_present_prev){
        //   Serial.println("Tag gone");
        //   break;
        // }

        if (toReadData) {
          readAllData();
          // dataBuf[strlen((char*)dataBuf)] = 0x99;
          if (strncmp(dataBuf + strlen((char*)dataBuf), "END", 3) != 0){
            memcpy(dataBuf + strlen((char*)dataBuf), "END", 3);
          }          
          offset = 0;
        } else if (toWipeData) {
          wipeData();
        } else if (toWriteData) {
          char fieldname[4]{};
          byte pad[18];
          byte padsize = 18;
          MFRC522::StatusCode status;

          status = (MFRC522::StatusCode) mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A, 3, &key, &(mfrc522.uid));
          if (status != MFRC522::STATUS_OK) {
              Serial.print(F("PCD_Authenticate() failed: "));
              Serial.println(mfrc522.GetStatusCodeName(status));
              return;
          }
          status = (MFRC522::StatusCode) mfrc522.MIFARE_Read(1, pad, &padsize);
          if (status != MFRC522::STATUS_OK) {
            Serial.print(F("MIFARE_Read() failed1: "));
            Serial.println(mfrc522.GetStatusCodeName(status));
            return;
          }
          // blockAddr = 1 + ((uint)dataSize / 16) + ((uint)dataSize / 48);
          // blockAddr = (blockAddr + 1) % 4 == 0 ? blockAddr + 1 : blockAddr;
          
          // wipeData();
          if (strlen((char*)pad) < 10) {
            Serial.println("COPYINH!@");
            memcpy(dataBuf, testData, sizeof(testData));
          }
          deserializeJson(doc, dataBuf);
          if ((pCharacteristic->getValue()).c_str() + 1 != 0) {
            strncpy(fieldname, pCharacteristic->getValue().c_str() + 1, 4);
            // PRINTF("Got data %s\n", (pCharacteristic->getValue()).c_str() + 5);
            // PRINTF("Default buf written: %s\n", dataBuf);
            doc[fieldname] = (char*)(pCharacteristic->getValue().c_str() + 5);
            PRINTF("Got fieldname %s\n", fieldname);
            PRINTF("Writing %s\n", pCharacteristic->getValue().c_str() + 5);
            PRINTF("wrote: %s\n", doc[fieldname]);
            serializeJson(doc, dataBuf);
            serializeJson(doc, Serial);
          }
          
          writeAllData();
          // writeDataSection(dataBlock, blockAddr);
          // readAllData();
        }

        toReadData = false;
        toWriteData = false;
        toWipeData = false;

        // Halt PICC
        mfrc522.PICC_HaltA();
        // Stop encryption on PCD
        mfrc522.PCD_StopCrypto1();
      // }
      
      
    }
    
}

/**
 * Helper routine to dump a byte array as hex values to Serial.
 */
void dump_byte_array(byte *buffer, byte bufferSize) {
    for (byte i = 0; i < bufferSize; i++) {
        Serial.print(buffer[i] < 0x10 ? " 0" : " ");
        Serial.print(buffer[i], HEX);
    }
}

bool writeDataSection(byte *dataBlock, byte blockAddr) {
    byte trailerBlock = ((blockAddr / 4) + 1) * 4 - 1;
    MFRC522::StatusCode status;
    byte buffer[18];
    byte size = sizeof(buffer);

    status = (MFRC522::StatusCode) mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A, trailerBlock, &key, &(mfrc522.uid));
    if (status != MFRC522::STATUS_OK) {
        Serial.print(F("PCD_Authenticate() failed: "));
        Serial.println(mfrc522.GetStatusCodeName(status));
        return false;
    }

    // Write data to the block
    Serial.print(F("Writing data into block ")); Serial.print(blockAddr);
    Serial.println(F(" ..."));
    dump_byte_array(dataBlock, 16); Serial.println();
    status = (MFRC522::StatusCode) mfrc522.MIFARE_Write(blockAddr, dataBlock, 16);
    if (status != MFRC522::STATUS_OK) {
        Serial.print(F("MIFARE_Write() failed: "));
        Serial.println(mfrc522.GetStatusCodeName(status));
    }
    Serial.println();

    status = (MFRC522::StatusCode) mfrc522.MIFARE_Read(blockAddr, buffer, &size);
    if (status != MFRC522::STATUS_OK) {
      Serial.print(F("MIFARE_Read() failed2: "));
      Serial.println(mfrc522.GetStatusCodeName(status));
      return false;
    }

    // Check that data in block is what we have written
    // by counting the number of bytes that are equal
    Serial.println(F("Checking result..."));
    byte count = 0;
    for (byte i = 0; i < 16; i++) {
        // Compare buffer (= what we've read) with dataBlock (= what we've written)
        if (buffer[i] == dataBlock[i])
            count++;
    }
    Serial.print(F("Number of bytes that match = ")); Serial.println(count);
    if (count == 16) {
        Serial.println(F("Success :-)"));
        return true;
    } else {
        Serial.println(F("Failure, no match :-("));
        Serial.println(F("  perhaps the write didn't work properly..."));
        return false;
    }
}

bool writeAllData() {
  int blockAddr = 0;
  byte trailerBlock = 3;
  MFRC522::StatusCode status;
  byte linebuf[18]{};
  
  Serial.println("Writing all data...");
  for (int i=0; i < 16; i++) {
    trailerBlock = (i + 1) * 4 - 1;
    status = (MFRC522::StatusCode) mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A, trailerBlock, &key, &(mfrc522.uid));
    if (status != MFRC522::STATUS_OK) {
        Serial.print(F("PCD_Authenticate() failed: "));
        Serial.println(mfrc522.GetStatusCodeName(status));
        return false;
    }
    Serial.println("Auth finished!");
    for (int j=0; j < 3; j++) {
      blockAddr = i * 4 + j;
      if (!blockAddr) continue;
      memcpy(linebuf, dataBuf + (blockAddr - (blockAddr / 4) - 1) * 16, 16);
      PRINTF("WRiting to %d %s\n", blockAddr, linebuf);
      status = (MFRC522::StatusCode) mfrc522.MIFARE_Write(blockAddr, linebuf, 16);
      memset(linebuf, 0, sizeof(linebuf));
      PRINTF("%d\n", (blockAddr - (blockAddr / 4) - 1) * 16);
      if (status != MFRC522::STATUS_OK) {
          Serial.print(F("MIFARE_Write() failed: "));
          Serial.println(mfrc522.GetStatusCodeName(status));
          return false;
      }
    }
  }

  Serial.println();
  Serial.println("Done writing data!");

  return true;
}

void readAllData() {
  int blockAddr = 0;
  byte line[18];
  byte size = sizeof(line);
  byte trailerBlock = 3;
  MFRC522::StatusCode status;
  
  Serial.println("Reading all data...");
  for (int i=0; i < 16; i++) {
    trailerBlock = (i + 1) * 4 - 1;
    status = (MFRC522::StatusCode) mfrc522.PCD_Authenticate(MFRC522::PICC_CMD_MF_AUTH_KEY_A, trailerBlock, &key, &(mfrc522.uid));
    if (status != MFRC522::STATUS_OK) {
        Serial.print(F("PCD_Authenticate() failed: "));
        Serial.println(mfrc522.GetStatusCodeName(status));
        return;
    }
    for (int j=0; j < 3; j++) {
      blockAddr = i * 4 + j;
      if (!blockAddr) continue;
      status = (MFRC522::StatusCode) mfrc522.MIFARE_Read(blockAddr, line, &size);
      if (status != MFRC522::STATUS_OK) {
        Serial.print(F("MIFARE_Read() failed3: "));
        Serial.println(mfrc522.GetStatusCodeName(status));
        return;
      }
      memcpy(dataBuf + (blockAddr - i - 1) * 0x10, line, 16);
      PRINTF("STEST: %d %s\n", (blockAddr - i - 1) * 0x10, line);
    }
  }

  for (int i=0; i < maxSize; i++) {
    if (i % 0x10 == 0) Serial.println();
    PRINTF("%c ", dataBuf[i]);
  }

  Serial.println();
  Serial.println("Done reading data!");

  return;
}

void wipeData() {
  Serial.println("Wiping data!");
  memset(dataBuf, 0, sizeof(dataBuf));
  writeAllData();
}
