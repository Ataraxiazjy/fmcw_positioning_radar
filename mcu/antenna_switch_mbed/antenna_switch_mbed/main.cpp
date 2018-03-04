#include <mbed.h>
#include <vector>
#include <bitset>
using namespace std;

#define WIDTH_FALL 0
#define WIDTH_PULSE 30
#define WIDTH_BIT 50

InterruptIn triger(D2);
DigitalInOut usrpSyn(D3, PIN_OUTPUT, OpenDrainNoPull, 1);
vector<DigitalOut>  switchsRx{ D4,D5,D6,D7};
vector<DigitalOut>  switchsTx{ D8,D9 };
bitset<4> iRx(0);
bitset<2> iTx(0);

void switchAnt()
{
	//�л�����
	size_t iB = 0;
	for (auto &dout : switchsRx)
	{
		dout = iRx[iB];
		++iB;
	}

	iB = 0;
	for (auto &dout : switchsTx)
	{
		dout = iTx[iB];
		++iB;
	}

	//��������
	wait_us(WIDTH_FALL);
	usrpSyn=0;
	wait_us(WIDTH_PULSE);

	//�������߱��
	for (int i = iRx.size() - 1; i >= 0; --i)
	{
		usrpSyn = iRx[i];
		wait_us(WIDTH_BIT);
	}
	for (int i = iTx.size() - 1; i >= 0; --i)
	{
		usrpSyn = iTx[i];
		wait_us(WIDTH_BIT);
	}
	
	

	//�������
	usrpSyn = 1;
	
	
	if (iRx.to_ulong() >= 11)
	{
		iRx = 0;

		if (iTx.to_ulong() >= 3)
		{
			iTx = 0;
		}
		else
		{
			iTx = iTx.to_ulong() + 1;
		}
	}
	else
	{
		iRx = iRx.to_ulong() + 1;
	}
}

int main() 
{
	triger.fall(&switchAnt);
	for (;;)
	{
	}
}