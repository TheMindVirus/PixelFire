#include <Ethernet.h>

#define Server_localIP() Ethernet.localIP()
#define Server_localPort() 80 //DNS?
#define Server_remoteIP() Client.remoteIP()
#define Server_remotePort() Client.localPort()

#define Server_Idle            0
#define Server_RenewError      1
#define Server_RenewSuccess    2
#define Server_RebindError     3
#define Server_RebindSuccess   4
#define Server_InitSuccess     5

#define Server_StatusOK "HTTP/1.1 200 OK\r\n"

int status = Server_Idle;
byte MAC[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
IPAddress IP = { 192, 168, 1, 177 }; //DHCP?
EthernetServer Server(Server_localPort());
//EthernetClient Client();
bool BlankLine = true;
char TempChar = '\0';
bool OneShot = true;

const char Server_Data[] PROGMEM = 
"\
<svg xmlns=\"http://www.w3.org/2000/svg\" style=\"position: fixed; top: 0; left: 0; width: 100%; height: 100%;\">\r\n\
<rect width=\"100%\" height=\"100%\" fill=\"#FF0\"></rect>\r\n\
<g id=\"budamilk\" fill=\"none\" stroke=\"#000\" stroke-linejoin=\"round\" stroke-linecap=\"round\">  \r\n\
  <path d=\"m  455 295 l 0.001 0.001 m 170 0 l 0.001 0.001 m 675 0 l 0.001 0.001 m 170 0 l 0.001 0.001\" stroke-width=\"18\"></path>\r\n\
  <path d=\"m  505 305 l 70 0 m 775 0 l 70 0\" stroke-width=\"12\"></path>\r\n\
  <path d=\"m  655 195 l 0 70 s 0 35 35 35 m 0 0 s 35 0 35 -35 m 0 0 s 0 -35 -35 -35 m 0 0 s -35 0 -35 35 m 0 0\" stroke-width=\"12\"></path>\r\n\
  <path d=\"m  745 230 l 0 35 s 0 35 35 35 m 0 0 s 35 0 35 -35 m 0 0 l 0 -35 l 0 70\" stroke-width=\"12\"></path>\r\n\
  <path d=\"m  905 195 l 0 70 s 0 35 -35 35 m 0 0 s -35 0 -35 -35 m 0 0 s 0 -35 35 -35 m 0 0 s 35 0 35 35 m 0 0\" stroke-width=\"12\"></path>\r\n\
  <path d=\"m  995 300 l 0 -35 s 0 35 -35 35 m 0 0 s -35 0 -35 -35 m 0 0 s 0 -35 35 -35 m 0 0 s 35 0 35 35 m 0 0\" stroke-width=\"12\"></path>\r\n\
  <path d=\"m 1015 230 l 0 70 l 0 -45 s 0 -25 25 -25 m 0 0 s 25 0 25 25 m 0 45 l 0 -45 s 0 -25 25 -25 m 0 0 s 25 0 25 25 l 0 45\" stroke-width=\"12\"></path>\r\n\
  <path d=\"m 1145 300 l 0 -25 l 0 -25\" stroke-width=\"12\"></path><path d=\"m 1145 220 l 0.001 0.001\" stroke-width=\"18\"></path>\r\n\
  <path d=\"m 1175 195 l 0 95 s 0 10 10 10\" stroke-width=\"12\"></path>\r\n\
  <path d=\"m 1215 195 l 0 105 m 0 -20 l 50 -50 m -30 30 l 40 40\" stroke-width=\"12\"></path>\r\n\
</g>\r\n\
<text x=\"520\" y=\"700\" font-size=\"350\" fill=\"#FFF\">&#x1F610;&#x1F95B;</text>\r\n\
</svg>\r\n\
";

const size_t Server_DataLength = sizeof(Server_Data);
//const size_t Server_FontLength = 25110; //221717; //sizeof(Server_Font);

char* Server_Headers(size_t data_length)
{
    char buffer[255] = "\0"; //Null Terminators required only here for strcat
    char* headers = "\0";
    strcat(headers,
"\
HTTP/1.1 200 OK\r\n\
Content-Type: text/html\r\n\
Content-Length: \
");
    itoa(data_length, buffer, 10);
    strcat(headers, buffer);
    strcat(headers,
"\
\r\n\
Connection: close\r\n\
\r\n\
");
    return headers;
}

const int Server_BufferLength = 255;
char Server_Buffer[Server_BufferLength] = {};
size_t Server_BufferOffset = 0;

void Server_BufferClear()
{
    for (size_t i = 0; i < Server_BufferLength; ++i)
    {
        Server_Buffer[i] = "\0";
    }
    Server_BufferOffset = 0;
}

void setup()
{
    Serial.begin(115200);
    Serial.print("[INFO]: ");
    Serial.println("budamilk");
    Server_BufferClear();
    //Ethernet.begin(MAC);
    Ethernet.begin(MAC, IP);
    Server.begin();
    OneShot = true;
}

void loop()
{
    status = Ethernet.maintain() + (OneShot ? Server_InitSuccess : 0);
    switch (status)
    {
        case (Server_InitSuccess): OneShot = false;
        case (Server_RenewSuccess):
        case (Server_RebindSuccess):
        {
            Serial.print("[INFO]: ");
            Serial.print("Server: ");
            Serial.print(Server_localIP());
            Serial.print(":");
            Serial.println(Server_localPort());
        }
        break;
        case (Server_RenewError):
        case (Server_RebindError):
        {
            Serial.print("[WARN]: ");
            Serial.print("Server: ");
            Serial.println("Error");
        }
        break;
        case (Server_Idle):
        default:
        {
            //Serial.println(status);
        }
        break;
    }
    
    EthernetClient Client = Server.available();
    if (Client)
    {
        //Serial.print("[INFO]: ");
        //Serial.print("Client: ");
        //Serial.print(Server_remoteIP());
        //Serial.print(":");
        //Serial.println(Server_remotePort());
        while (Client.connected())
        {
            while (Client.available())
            {
                Server_Buffer[Server_BufferOffset] = Client.read();
                if (Server_BufferOffset < Server_BufferLength) { Server_BufferOffset += 1; }
                else { break; }
            }
            char* ptr = strtok(Server_Buffer, '\n');
            while (ptr != nullptr)
            {
                if ((ptr[0] == 'G')
                &&  (ptr[1] == 'E')
                &&  (ptr[2] == 'T'))
                {
                    if (ptr[5] == ' ')
                    {
                        //Serial.println(Server_Buffer);
                        Client.println(Server_Headers(Server_DataLength));
                        for (size_t i = 0; i < Server_DataLength; ++i)
                        {
                            Client.print((char)pgm_read_byte(&(Server_Data[i])));
                        }
                    }
                    /*else
                    {
                        //Serial.println(Server_Buffer);
                        Client.println(Server_Headers(Server_FontLength));
                        for (size_t i = 0; i < Server_FontLength; ++i)
                        {Client.print(Server_StatusOK);
                            //Client.print((char)pgm_read_byte(&(Server_Font[i])));
                        }
                    }*/
                }
                ptr = strtok(nullptr, '\n');
            }
            Server_BufferClear();
            break;
        }
        delay(10);
        Client.stop();
    }
}
