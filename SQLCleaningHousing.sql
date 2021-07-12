/*

Cleaning Data in SQL Queries
NashvilleHousing dataset

Skills used: Joins, CTE's, Windows Functions, PARSENAME, CHARINDEX, Converting Data Types

*/


SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing;

---------------------------------------------------------------------------------------

--Standardize Date Format


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted= CONVERT (Date,SaleDate);


---------------------------------------------------------------------------------------

--Populate Property Address data

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID= b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null;


---------------------------------------------------------------------------------------

--Breaking out Address into individual columns (Address, City, state)

--Split PropertyAddress into 2 new columns using SUBSTRING
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;


SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1 ) as Address
, SUBSTRING (PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN(PropertyAddress )) as Address
,PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitAddress= SUBSTRING (PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1 );


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING (PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN(PropertyAddress ));



--Split OwnerAddress into 3 new columns using PARSENAME


SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;


SELECT
PARSENAME (REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME (REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME (REPLACE(OwnerAddress, ',','.'),1)
,OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitAddress= PARSENAME (REPLACE(OwnerAddress, ',','.'),3);


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitCity= PARSENAME (REPLACE(OwnerAddress, ',','.'),2);


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitState= PARSENAME (REPLACE(OwnerAddress, ',','.'),1);


---------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT (SoldASVacant) , Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;


---------------------------------------------------------------------------------------


--Remove Duplicates


--First identify how many duplicate rows are present

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT * 
FROM RowNumCTE
WHERE row_num>1
ORDER BY PropertyAddress;

--Swap select statement with delete to remove duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num>1
--Order BY PropertyAddress;

---------------------------------------------------------------------------------------

--Delete unused columns


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate;

