--*/
SELECT *
from [Portfolio Project]..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

--information for data

select *
from INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME = 'NashvilleHousing'

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT  SaleDateConvert , CONVERT(date,SaleDate)
from [Portfolio Project]..NashvilleHousing


update NashvilleHousing 
set SaleDate=CONVERT(date,SaleDate)    --didn't work

alter table NashvilleHousing
add SaleDateConvert date ;

Update NashvilleHousing
SET SaleDateConvert = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

select  *
from [Portfolio Project] ..NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project]..NashvilleHousing a
join [Portfolio Project]..NashvilleHousing b
 on a.ParcelID=b.ParcelID
 and a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from [Portfolio Project]..NashvilleHousing


select
SUBSTRING( PropertyAddress,-1,CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING( PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as address
from [Portfolio Project]..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--------------------------------------------------------------------------------------------------------------------------
-- owner address

select OwnerAddress
from [Portfolio Project]..NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from [Portfolio Project]..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress,',','.'),2)


Alter Table NashvilleHousing
add OwnerSplitstate Nvarchar(255);


update NashvilleHousing
set OwnerSplitstate=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from [Portfolio Project]..NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant),count(SoldAsVacant)
from [Portfolio Project]..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when  SoldAsVacant='Y' then  'Yes'
		when SoldAsVacant='N' then'No'
		ELSE SoldAsVacant
		end
from [Portfolio Project]..NashvilleHousing


update NashvilleHousing
set SoldAsVacant =case when  SoldAsVacant='Y' then  'Yes'
when SoldAsVacant='N' then'No'
ELSE SoldAsVacant
end




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

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

From [Portfolio Project]..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [Portfolio Project]..NashvilleHousing


ALTER TABLE [Portfolio Project]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
