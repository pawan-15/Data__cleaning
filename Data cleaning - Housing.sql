/*
Cleaning data using SQL queries
*/
SELECT *
FROM master.dbo.housing


-- Standardize Date format
SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM master.dbo.housing

UPDATE housing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE housing
add SaleDateConverted Date;

UPDATE housing
SET SaleDateConverted = CONVERT(date,SaleDate)



-- Populate property adress

SELECT PropertyAddress
FROM master.dbo.housing




SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM master.dbo.housing a 
JOIN master.dbo.housing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueId] <> b.[UniqueId]
--WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM master.dbo.housing a 
JOIN master.dbo.housing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueId] <> b.[UniqueId]
WHERE a.PropertyAddress is null


-- Breaking out address into city state


SELECT PropertyAddress
FROM master.dbo.housing

SELECT
SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress)-1) AS address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1 , LEN(PropertyAddress)) AS city
FROM master.dbo.housing



ALTER TABLE housing
add PropertySplitAddress Nvarchar(255);

UPDATE housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',' , PropertyAddress)-1)

ALTER TABLE housing
add PropertySplitCity Nvarchar(255);

UPDATE housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1 , LEN(PropertyAddress))


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)
FROM master.dbo.housing


ALTER TABLE housing
add OwnerSplitAddress Nvarchar(255);

UPDATE housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),3)



ALTER TABLE housing
add OwnerSplitCity Nvarchar(255);

UPDATE housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),2)


ALTER TABLE housing
add OwnerSplitState Nvarchar(255);

UPDATE housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'),1)


-- Change Y and N to yes and no in SoldAsVaccant

SELECT DISTINCT(SoldAsVacant)
FROM master.dbo.housing


SELECT SoldAsVacant,
 CASE When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM master.dbo.housing


UPDATE housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END



-- Removing Duplicates


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

FROM master.dbo.housing 
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress 


-- Removing unused columns

SELECT *
FROM master.dbo.housing


ALTER TABLE housing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict


ALTER TABLE housing
DROP COLUMN SaleDate












