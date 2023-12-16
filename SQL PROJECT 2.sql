--DATA CLEANING IN SQL QUERIES
--Q)select all data from nash housing table 
select * from
portfolioprojects.dbo.NashvilleHousing

Q1)STANDARDIZING THE DATE BY REMOVING TIMESTAMP WHICH IS NOT THAT USEFUL
select SaleDate 
from portfolioprojects.dbo.NashvilleHousing

--removed timestamp
select SaleDate,convert(date,SaleDate)
from portfolioprojects.dbo.NashvilleHousing

--updating it in the table
update portfolioprojects.dbo.NashvilleHousing
set SaleDate=convert(date,SaleDate)

--but it does not get updated so we try another methods by add one new column to the table 
alter table portfolioprojects.dbo.NashvilleHousing
add SaleDateconvert date;

--now updating this new column
update  portfolioprojects.dbo.NashvilleHousing
set SaleDateconvert=convert(date,SaleDate)

select SaleDateconvert
from portfolioprojects.dbo.NashvilleHousing

--deleting on already existing same column
ALTER TABLE portfolioprojects.dbo.NashvilleHousing
DROP COLUMN SaleDateConverted;
--Q2)filling null values of property address column with the values of propert address having same ParcelID 
--firstly we will see all nullvalues acc to parcel id
select PropertyAddress 
from portfolioprojects.dbo.NashvilleHousing
where PropertyAddress is null
order by ParcelID
--second we see null values by joning the table to itself ,here we will get to know parcel id is same but still addres is not given so in next step we update that null adress acc to parcel id 
select a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID,ISNULL( a.PropertyAddress,b.PropertyAddress)
from portfolioprojects.dbo.NashvilleHousing a
join portfolioprojects.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
--third we update null values
update a
set PropertyAddress=ISNULL( a.PropertyAddress,b.PropertyAddress)
from portfolioprojects.dbo.NashvilleHousing a
join portfolioprojects.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


Q3)breaking address into three separete columns that is :adress,city,state
select PropertyAddress
from portfolioprojects.dbo.NashvilleHousing
--NOTE: -1 is to remove the comma like going  to the comma by charindex() and then removing it
select 
SUBSTRING( PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as address
from portfolioprojects.dbo.NashvilleHousing

--now instead of first position we have to start with the position of comma,+1 coz we ned to do till comma and then the length
select
SUBSTRING( PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as address,
SUBSTRING( PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from portfolioprojects.dbo.NashvilleHousing

--Q)separating differnt values into different column from one column 
alter table portfolioprojects.dbo.NashvilleHousing
add PropertySplitAdress nvarchar(255);

update  portfolioprojects.dbo.NashvilleHousing
set PropertySplitAdress=SUBSTRING( PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) 

alter table portfolioprojects.dbo.NashvilleHousing
add PropertysplitCity nvarchar(255);

update  portfolioprojects.dbo.NashvilleHousing
set PropertysplitCity=SUBSTRING( PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

--now lets see this new columns
select * from
portfolioprojects.dbo.NashvilleHousing
Q)like same above do for owner adress in another way
select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
from
portfolioprojects.dbo.NashvilleHousing

--now update it in main table
alter table portfolioprojects.dbo.NashvilleHousing
add OwnerSplitAdress nvarchar(255);

update  portfolioprojects.dbo.NashvilleHousing
set OwnerSplitAdress=PARSENAME(Replace(OwnerAddress,',','.'),3) 

alter table portfolioprojects.dbo.NashvilleHousing
add OwnersplitCity nvarchar(255);

update  portfolioprojects.dbo.NashvilleHousing
set OwnersplitCity=PARSENAME(Replace(OwnerAddress,',','.'),2)

alter table portfolioprojects.dbo.NashvilleHousing
add OwnersplitState nvarchar(255);

update  portfolioprojects.dbo.NashvilleHousing
set OwnersplitState=PARSENAME(Replace(OwnerAddress,',','.'),1)

--now lets see above updation in main table
select * from
portfolioprojects.dbo.NashvilleHousing

Q)Replacing Y OR N in SoldAsVacant column with yes or no
select distinct SoldAsVacant,count(SoldAsVacant)
from portfolioprojects.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

--as count of yes and no is more as compared to y and n so we replace y and n with yes and no
select SoldAsVacant
,case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else  SoldAsVacant
end
from portfolioprojects.dbo.NashvilleHousing

--now lets update it in main table
update  portfolioprojects.dbo.NashvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else  SoldAsVacant
end
from portfolioprojects.dbo.NashvilleHousing

--Q)removing duplicate data
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjects.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Q)removing unused columns

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

Select *
From portfolioprojects.dbo.NashvilleHousing

