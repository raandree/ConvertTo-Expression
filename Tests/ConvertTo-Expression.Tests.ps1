$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Function Should-BeEqualTo ($Value2, [Parameter(ValueFromPipeLine = $True)]$Value1) {
	$Value1 | Should -Be $Value2
	$Value1 | Should -BeOfType $Value2.GetType().Name
}

Describe 'ConvertTo-Expression' {
	
	$Version  = $PSVersionTable.PSVersion
	$Guid = [GUID]'5f167621-6abe-4153-a26c-f643e1716720'
	$TimeSpan = New-TimeSpan -Hour 1 -Minute 25
	$DateTime = Get-Date
	Mock Get-Date -ParameterFilter {$null -eq $Date} {$DateTime}
	
	Context 'custom object' {

	$DataTable = New-Object Data.DataTable
	$DataColumn = New-Object Data.DataColumn
	$DataColumn.ColumnName = "Name"
	$DataTable.Columns.Add($DataColumn)
	$DataRow = $DataTable.NewRow()
	$DataRow.Item("Name") = "Hello"
	$DataTable.Rows.Add($DataRow)
	$DataRow = $DataTable.NewRow()
	$DataRow.Item("Name") = "World"
	$DataTable.Rows.Add($DataRow)

	$Object = @{
		String     = [String]"String"
		Text       = [String]"Hello`r`nWorld"
		Char       = [Char]65
		Byte       = [Byte]66
		Int        = [Int]67
		Long       = [Long]68
		Null       = $Null
		Booleans   = $False, $True
		Decimal    = [Decimal]69
		Single     = [Single]70
		Double     = [Double]71
		DateTime   = $DateTime
		TimeSpan   = $TimeSpan
		Version    = $Version
		Guid       = $Guid
		Script     = {2 * 3}
		Array      = @("One", "Two", @("Three", "Four"), "Five")
		EmptyArray = @()
		HashTable  = @{city="New York"; currency="Dollar	(`$)"; postalCode=10021; Etc = @("Three", "Four", "Five")}
		Ordered    = [Ordered]@{One = 1; Two = 2; Three = 3; Four = 4}
		Object     = New-Object PSObject -Property @{Name = "One"; Value = 1; Group = @("First", "Last")}
		DataTable  = $DataTable
		Xml        = [Xml]@"
			<items>
				<item id="0001" type="donut">
					<name>Cake</name>
					<ppu>0.55</ppu>
					<batters>
						<batter id="1001">Regular</batter>
						<batter id="1002">Chocolate</batter>
						<batter id="1003">Blueberry</batter>
					</batters>
					<topping id="5001">None</topping>
					<topping id="5002">Glazed</topping>
					<topping id="5005">Sugar</topping>
					<topping id="5006">Sprinkles</topping>
					<topping id="5003">Chocolate</topping>
					<topping id="5004">Maple</topping>
				</item>

			</items>
"@
	}

		It "casts type" {
			
			$Expression = $Object | ConvertTo-Expression
			
			$Actual = &$Expression
			
			$Actual.String      | Should -Be $Object.String
			$Actual.Text        | Should -Be $Object.Text
			$Actual.Char        | Should -Be $Object.Char
			$Actual.Byte        | Should -Be $Object.Byte
			$Actual.Int         | Should -Be $Object.Int
			$Actual.Long        | Should -Be $Object.Long
			$Actual.Null        | Should -Be $Object.Null
			$Actual.Booleans[0] | Should -Be $Object.Booleans[0]
			$Actual.Booleans[1] | Should -Be $Object.Booleans[1]
			$Actual.Decimal     | Should -Be $Object.Decimal
			$Actual.Single      | Should -Be $Object.Single
			$Actual.Double      | Should -Be $Object.Double
			$Actual.Long        | Should -Be $Object.Long
			$Actual.DateTime    | Should -Be $DateTime
			$Actual.TimeSpan    | Should -Be $TimeSpan
			$Actual.Version     | Should -Be $Version
			$Actual.Guid        | Should -Be $Guid
			&$Actual.Script     | Should -Be (&$Object.Script)
			$Actual.Array       | Should -Be $Object.Array
			,$Actual.EmptyArray | Should -BeOfType [Array]
			$Actual.HashTable.City       | Should -Be $Object.HashTable.City
			$Actual.HashTable.Currency   | Should -Be $Object.HashTable.Currency
			$Actual.HashTable.PostalCode | Should -Be $Object.HashTable.PostalCode
			$Actual.HashTable.Etc        | Should -Be $Object.HashTable.Etc
			$Actual.Ordered.One          | Should -Be $Object.Ordered.One
			$Actual.Ordered.Two          | Should -Be $Object.Ordered.Two
			$Actual.Ordered.Three        | Should -Be $Object.Ordered.Three
			$Actual.Ordered.Four         | Should -Be $Object.Ordered.Four
			$Actual.Object.Name          | Should -Be $Object.Object.Name
			$Actual.Object.Value         | Should -Be $Object.Object.Value
			$Actual.Object.Group         | Should -Be $Object.Object.Group
			$Actual.DataTable.Name[0]    | Should -Be $Object.DataTable.Name[0]
			$Actual.DataTable.Name[1]    | Should -Be $Object.DataTable.Name[1]
		}
		
		It "compress" {
			
			$Expression = $Object | ConvertTo-Expression -Expand -1
			
			$Actual = &$Expression
			
			$Actual.String      | Should -Be $Object.String
			$Actual.Text        | Should -Be $Object.Text
			$Actual.Char        | Should -Be $Object.Char
			$Actual.Byte        | Should -Be $Object.Byte
			$Actual.Int         | Should -Be $Object.Int
			$Actual.Long        | Should -Be $Object.Long
			$Actual.Null        | Should -Be $Object.Null
			$Actual.Booleans[0] | Should -Be $Object.Booleans[0]
			$Actual.Booleans[1] | Should -Be $Object.Booleans[1]
			$Actual.Decimal     | Should -Be $Object.Decimal
			$Actual.Single      | Should -Be $Object.Single
			$Actual.Double      | Should -Be $Object.Double
			$Actual.Long        | Should -Be $Object.Long
			$Actual.DateTime    | Should -Be $DateTime
			$Actual.TimeSpan    | Should -Be $TimeSpan
			$Actual.Guid        | Should -Be $Guid
			$Actual.Version     | Should -Be $Version
			&$Actual.Script     | Should -Be (&$Object.Script)
			$Actual.Array       | Should -Be $Object.Array
			,$Actual.EmptyArray | Should -BeOfType [Array]
			$Actual.HashTable.City       | Should -Be $Object.HashTable.City
			$Actual.HashTable.Currency   | Should -Be $Object.HashTable.Currency
			$Actual.HashTable.PostalCode | Should -Be $Object.HashTable.PostalCode
			$Actual.HashTable.Etc        | Should -Be $Object.HashTable.Etc
			$Actual.Ordered.One          | Should -Be $Object.Ordered.One
			$Actual.Ordered.Two          | Should -Be $Object.Ordered.Two
			$Actual.Ordered.Three        | Should -Be $Object.Ordered.Three
			$Actual.Ordered.Four         | Should -Be $Object.Ordered.Four
			$Actual.Object.Name          | Should -Be $Object.Object.Name
			$Actual.Object.Value         | Should -Be $Object.Object.Value
			$Actual.Object.Group         | Should -Be $Object.Object.Group
			$Actual.DataTable.Name[0]    | Should -Be $Object.DataTable.Name[0]
			$Actual.DataTable.Name[1]    | Should -Be $Object.DataTable.Name[1]
		}
		
		It "converts strict type" {
			
			$Expression = $Object | ConvertTo-Expression -Type Strict
			
			$Actual = &$Expression
			
			$Actual.String      | Should-BeEqualTo $Object.String
			$Actual.Text        | Should-BeEqualTo $Object.Text
			$Actual.Char        | Should-BeEqualTo $Object.Char
			$Actual.Byte        | Should-BeEqualTo $Object.Byte
			$Actual.Int         | Should-BeEqualTo $Object.Int
			$Actual.Long        | Should-BeEqualTo $Object.Long
			$Actual.Null        | Should -Be $Object.Null
			$Actual.Booleans[0] | Should-BeEqualTo $Object.Booleans[0]
			$Actual.Booleans[1] | Should-BeEqualTo $Object.Booleans[1]
			$Actual.Decimal     | Should-BeEqualTo $Object.Decimal
			$Actual.Single      | Should-BeEqualTo $Object.Single
			$Actual.Double      | Should-BeEqualTo $Object.Double
			$Actual.Long        | Should-BeEqualTo $Object.Long
			$Actual.DateTime    | Should-BeEqualTo $DateTime
			$Actual.TimeSpan    | Should-BeEqualTo $TimeSpan
			$Actual.Version     | Should-BeEqualTo $Version
			$Actual.Guid        | Should-BeEqualTo $Guid
			&$Actual.Script     | Should-BeEqualTo (&$Object.Script)
			$Actual.Array       | Should -Be $Object.Array
			,$Actual.EmptyArray | Should -BeOfType [Array]
			$Actual.HashTable.City       | Should -Be $Object.HashTable.City
			$Actual.HashTable.Currency   | Should -Be $Object.HashTable.Currency
			$Actual.HashTable.PostalCode | Should -Be $Object.HashTable.PostalCode
			$Actual.HashTable.Etc        | Should -Be $Object.HashTable.Etc
			$Actual.Ordered.One          | Should -Be $Object.Ordered.One
			$Actual.Ordered.Two          | Should -Be $Object.Ordered.Two
			$Actual.Ordered.Three        | Should -Be $Object.Ordered.Three
			$Actual.Ordered.Four         | Should -Be $Object.Ordered.Four
			$Actual.Object.Name          | Should -Be $Object.Object.Name
			$Actual.Object.Value         | Should -Be $Object.Object.Value
			$Actual.Object.Group         | Should -Be $Object.Object.Group
			$Actual.DataTable.Name[0]    | Should -Be $Object.DataTable.Name[0]
			$Actual.DataTable.Name[1]    | Should -Be $Object.DataTable.Name[1]
			$Actual.XML                  | Should -BeOfType [System.Xml.XmlDocument]
		}
		
		It "convert calendar to expression" {
		
			$Calendar = (Get-UICulture).Calendar
			
			$Expression = $Calendar | ConvertTo-Expression
			
			$Actual = &$Expression
		
			$Actual.AlgorithmType        | Should -Be $Calendar.AlgorithmType
			$Actual.CalendarType         | Should -Be $Calendar.CalendarType
			$Actual.Eras                 | Should -Be $Calendar.Eras
			$Actual.IsReadOnly           | Should -Be $Calendar.IsReadOnly
			$Actual.MaxSupportedDateTime | Should -Be $Calendar.MaxSupportedDateTime
			$Actual.MinSupportedDateTime | Should -Be $Calendar.MinSupportedDateTime
			$Actual.TwoDigitYearMax      | Should -Be $Calendar.TwoDigitYearMax
			
		}

		It "compress ConvertTo-Expression" {
		
			$User = @{Account="User01";Domain="Domain01";Admin=$True}
			
			$Expression = $User | ConvertTo-Expression -Expand -1
			
			"$Expression".Contains(" ") | Should -Be $False
			
			$Actual = &$Expression
		
			$Actual.Account | Should-BeEqualTo $User.Account
			$Actual.Domain  | Should-BeEqualTo $User.Domain
			$Actual.Admin   | Should-BeEqualTo $User.Admin
			
		}

		It "convert Date" {
		
			$Date = Get-Date | Select-Object -Property *
			
			$Expression = $Date | ConvertTo-Expression 
			
			$Actual = &$Expression

			$Actual.Date        | Should -Be $Date.Date
			$Actual.DateTime    | Should -Be $Date.DateTime
			$Actual.Day         | Should -Be $Date.Day
			$Actual.DayOfWeek   | Should -Be $Date.DayOfWeek
			$Actual.DayOfYear   | Should -Be $Date.DayOfYear
			$Actual.DisplayHint | Should -Be $Date.DisplayHint
			$Actual.Hour        | Should -Be $Date.Hour
			$Actual.Kind        | Should -Be $Date.Kind
			$Actual.Millisecond | Should -Be $Date.Millisecond
			$Actual.Minute      | Should -Be $Date.Minute
			$Actual.Month       | Should -Be $Date.Month
			$Actual.Second      | Should -Be $Date.Second
			$Actual.Ticks       | Should -Be $Date.Ticks
			$Actual.TimeOfDay   | Should -Be $Date.TimeOfDay
			$Actual.Year        | Should -Be $Date.Year

		}
	}
	
	Context 'system objects' {

		It "convert (wininit) process" {
		
			$WinInitProcess = Get-Process WinInit

			$Expression = $WinInitProcess | ConvertTo-Expression 
			
			$Actual = &$Expression
			
			$Actual.ProcessName | Should-BeEqualTo $WinInitProcess.ProcessName
			
		}

		It "convert MyInvocation" {
		

			$Expression = $MyInvocation | ConvertTo-Expression 
			
			$Actual = &$Expression
			
			$Actual.MyCommand.Name | Should -Be $MyInvocation.MyCommand.Name
			
		}
	}
	Context 'special objects' {

		It "Null or empty variable" {
		
			$Null | ConvertTo-Expression | Should -be "`$Null"
		
		}

		It "Empty array" {
		
			,@() | ConvertTo-Expression | Should -be "@()"
		
		}

		It "Array containing null" {
		
			,@($Null) | ConvertTo-Expression | Should -be "@(`$Null)"
		
		}

		It "Array containing empty array" {
		
			,@(,@()) | ConvertTo-Expression | Should -be "@(@())"
		
		}

		It "Array containing two empty arrays" {
		
			,@(@(), @()) | ConvertTo-Expression -Expand 0 | Should -be "@(@(), @())"
		
		}

		It "Array containing two strings" {
		
			,@('One', 'Two') | ConvertTo-Expression -Expand 0 | Should -be "@('One', 'Two')"
		
		}

		It "Empty hash table" {
		
			@{} | ConvertTo-Expression | Should -be "@{}"
		
		}

	}
}

