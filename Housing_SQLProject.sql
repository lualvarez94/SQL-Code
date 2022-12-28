/*

Cleaning Data in SQL Queries

*/ 

select *
from dbo.housingdata

----------------------------------------------

-- Standardize Date format

select SaleDate, CONVERT(Date,SaleDate)
from dbo.housingdata

UPDATE dbo.housingdata
SET SaleDate = CONVERT(Date,SaleDate)

-- Alternate way of updating date format

ALTER TABLE dbo.housingdata
Add SaleDateConverted Date;

UPDATE dbo.housingdata
SET SaleDateConverted = CONVERT(Date,SaleDate)

----------------------------------------------

-- Populate Property Address data where column is null

select *
from dbo.housingdata
--where PropertyAddress is NULL
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housingdata a 
JOIN dbo.housingdata b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housingdata a 
JOIN dbo.housingdata b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is NULL

----------------------------------------------

-- Breaking out Address into Individual Columns (Address,City,State)

select PropertyAddress
from dbo.housingdata
order by ParcelID

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from dbo.housingdata

ALTER TABLE dbo.housingdata
Add PropertySplitAddress Nvarchar(255);

UPDATE dbo.housingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE dbo.housingdata
Add PropertySplitCity Nvarchar(255);

UPDATE dbo.housingdata
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from dbo.housingdata

select owneraddress
from dbo.housingdata

select PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from dbo.housingdata

ALTER TABLE dbo.housingdata
Add OwnerSplitAddress Nvarchar(255);

UPDATE dbo.housingdata
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE dbo.housingdata
Add OwnerSplitCity Nvarchar(255);

UPDATE dbo.housingdata
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE dbo.housingdata
Add OwnerSplitState Nvarchar(255);

UPDATE dbo.housingdata
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

select *
from dbo.housingdata

----------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from dbo.housingdata
Group by SoldAsVacant
Order by 2

select SoldAsVacant,
	CASE 
	When SoldAsVacant = '1' THEN 'Yes'
	When SoldAsVacant = '0' THEN 'No'
	END
from dbo.housingdata


----------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
select 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					)row_num
from dbo.housingdata
--order by ParcelID
)
select *
from RowNumCTE
Where row_num > 1
order by PropertyAddress


----------------------------------------------

-- Delete Unused Columns

select *
from dbo.housingdata

Alter table dbo.housingdata
drop column OwnerAddress, TaxDistrict, PropertyAddress

