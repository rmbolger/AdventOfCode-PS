# parse the data (safely; no iex), doing two things:
# 1. build a switch statement that turns $_ into the fields that it could belong to
# 2. for each ticket field, make an object with its Ticket #, Field Position, Value, and Possible Fields
$c=''
$t=0
$Tickets = switch -Regex(gcb){
  '(.*): (.*)' {
    $k,$v=$matches[1,2]
    $v-split'or'|%{
      $L,$H=$_-split'-'-as[int[]]
      $c+="{+`$_-ge$L-and+`$_-le$H}{'$($k-replace"'","''")'}"
    }
  }

  '^$' {$s="{switch(`$_){$c}}"|iex}

  ',' {
    $_-split','|%{$i=0}{
      [pscustomobject]@{
        Ticket = $t
        FieldPos = $i++
        Value = $_
        Fields = &$s | sort | gu
      }
    }
    $t++
  }
}

#Part 1, now trivial:
$Tickets |? Fields -eq $null| measure -sum value|% Sum

#Prepare some data for Part 2: All fields, and the fields in my ticket, indexed by position
$Fields=$Tickets.fields|sort|gu
$MyTicket = $Tickets|? ticket -eq 0|group -aht FieldPos

$Tickets|
? Fields| # filter out impossible fields

group ticket| # group fields into tickets

# group the tickets by the # of valid fields on the ticket, then sort by that
group count|sort{+$_.Name}|

# Get the fields from the valid tickets, which are in
# the group with the most valid fields.
select -last 1|% Group|% Group|

# figure out which fields this ticket field position can't possible be
select *,@{n='UnFields';e={$ValueFields=$_.Fields; $Fields|?{$_-notin$ValueFields}}}|#<#

group FieldPos|
# a field position can't be a particular field if any valid tickets can't be that field
select Name,@{n='Tickets';e={$_.Group.Ticket}},@{n='UnFields';e={$_.Group.UnFields|sort|gu}}|

# now we rely on lucky data rather than more rigorous logic:
# the field position with the most disallowed fields ends up with only 1 possible field,
# the next one has only 2 possible fields, one of which is the prior, so
# we can get rid of the already-known field and are left with 1. And so on.
sort{$_.UnFields.Count} -Descending |
select -ov Winners @{n='FieldPos';e='Name'},
       @{n='Field';e={
         $ValueUnFields=$_.UnFields
         $Fields|?{$_-notin@($ValueUnFields;$Winners.Field)}
       }}|

# filter to the fields specified in the problem, look up the field value on my ticket, multiply together, done.
? Field -like departure* |
select *, @{n='MyTicketValue';e={+$MyTicket[+$_.FieldPos].Value}}|
select *, @{n='CumulativeProduct';e={$_.MyTicketValue*$(if($prev){$prev.CumulativeProduct}else{1})}} -pv prev |#<#
select -last 1 |% CumulativeProduct
#>
ft
