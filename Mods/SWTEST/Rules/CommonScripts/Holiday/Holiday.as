// Holiday.as

// =========================================
// | Month     | Date | Days | Start | End |
// =========================================
// | January   | 01   | 31   | 001   | 031 |
// | February  | 02   | 28+  | 032   | 059 |
// | March     | 03   | 31   | 060   | 090 |
// | April     | 04   | 30   | 091   | 120 |
// | May       | 05   | 31   | 121   | 151 |
// | Juny      | 06   | 30   | 152   | 181 |
// | July      | 07   | 31   | 182   | 212 |
// | August    | 08   | 31   | 213   | 243 |
// | September | 09   | 30   | 244   | 273 |
// | October   | 10   | 31   | 274   | 304 |
// | November  | 11   | 30   | 305   | 334 |
// | December  | 12   | 31   | 335   | 365 |
// =========================================

#include "HolidayCommon.as";

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	if(getNet().isServer())
	{
		u16 server_year = Time_Year();
		s16 server_date = Time_YearDate();
		u8 server_leap = ((server_year % 4 == 0 && server_year % 100 != 0) || server_year % 400 == 0)? 1 : 0;

		Holiday[] calendar = {
			  Holiday("Birthday", 116 + server_leap - 1, 3)
			, Holiday("Halloween", 303 + server_leap - 1, 3)
			//, Holiday("Christmas", 358 + server_leap - 1, 3)
		};

		s16 holiday_date;
		u8 holiday_length;

		for(u8 i = 0; i < calendar.length; i++)
		{
			holiday_date = calendar[i].m_date;
			holiday_length = calendar[i].m_length;

			if(server_date - holiday_date >= 0 && server_date < holiday_date + holiday_length)
			{
				this.set_string("holiday", calendar[i].m_name);
				this.Sync("holiday", true);

				break;
			}
		}
	}

	if(this.exists("holiday"))
	{
		this.AddScript(this.get_string("holiday")+".as");
	}
}
