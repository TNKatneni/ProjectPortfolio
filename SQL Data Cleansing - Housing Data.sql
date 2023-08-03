/* Data Cleansing - Housing Data
*/

select * 
from PortfolioProject..NashvilleHousing


-- Standarize Date Format (Change from datetime format using CONVERT)

select NewSaleDate
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add NewSaleDate Date;

Update NashvilleHousing
Set NewSaleDate = CONVERT (Date,SaleDate)


-- Add Property Address Data 

select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null 
order by ParcelID



select c.ParcelID, c.PropertyAddress, d.ParcelID, d.PropertyAddress, ISNULL(c.PropertyAddress, d.PropertyAddress)
from PortfolioProject..NashvilleHousing c
Join PortfolioProject..NashvilleHousing d
	ON c.ParcelID = d.ParcelID
	AND c.[UniqueID ] <> d.[UniqueID ]
where c.PropertyAddress is null 

Update c
SET PropertyAddress = ISNULL(c.PropertyAddress, d.PropertyAddress)
from PortfolioProject..NashvilleHousing c
Join PortfolioProject..NashvilleHousing d
	ON c.ParcelID = d.ParcelID
	AND c.[UniqueID ] <> d.[UniqueID ]
where c.PropertyAddress is null 

-- Splitting address into individual columns (Address-City-State) Using SUBSTRING,CHARINDEX, PARSENAME, and REPLACE

select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null 
--order by ParcelID

Select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select * 
from PortfolioProject..NashvilleHousing

 

select OwnerAddress
from PortfolioProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-- Replace Y and N to Yes and No in SoldAsVacant Column - Using Case Statements

select distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject..NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject..NashvilleHousing


--Removing duplicates - Using ROW NUMBER, CTE, and Windows function PARTITION BY

WITH RowCTE AS (
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,  
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing

)
DELETE
from RowCTE
where row_num >1
--order by PropertyAddress



--Delete Old Columns

Select *
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
