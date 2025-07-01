/* 
 
Cleaning Data in SQL Queries 
 
*/ 
 
Select *
FROM PortfolioProject02.dbo.NashvilleHousing;

-------------------------------------------------------

---Standardize Date Format to Exclude Time Stamp

ALTER TABLE portfolioProject02..NashvilleHousing
ALTER COLUMN SaleDate DATE

/*

Populate Property Address Data to Replace Null Values Using Self Join
Because we Have a Unique ID For Each Duplicate Parcel ID we Are Able to 
Take The Address From The Matching Parcel ID And Replace The Null Values 
While Keeping The Rows Separated in The Join Statement Because of The Unique ID

*/

Select PropertyAddress
FROM PortfolioProject02.dbo.NashvilleHousing
WHERE PropertyAddress is NULL; 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject02.dbo.NashvilleHousing as A
JOIN PortfolioProject02..NashvilleHousing as B
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null;

UPDATE A
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject02.dbo.NashvilleHousing as A
JOIN PortfolioProject02..NashvilleHousing as B
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID;



-------------------------------------------------------


---Change any 'Y' and 'N' to Yes and No to Make the Data Consistent

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject02.dbo.NashvilleHousing;

UPDATE PortfolioProject02..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM PortfolioProject02.dbo.NashvilleHousing;

SELECT SoldAsVacant
FROM PortfolioProject02.dbo.NashvilleHousing
WHERE SoldAsVacant = 'N'
OR SoldAsVacant = 'Y';


-------------------------------------------------------


---Remove Duplicates Via CTE

WITH Row_Num_CTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	Saleprice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num

FROM PortfolioProject02.dbo.NashvilleHousing)

DELETE
FROM Row_Num_CTE
WHERE row_num > 1;

---Test to Make Sure Data was Deleted, Select Statement Should not Return any Data


WITH Row_Num_CTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	Saleprice,
	SaleDate,
	LegalReference
	ORDER BY 
		UniqueID
		) row_num

FROM PortfolioProject02.dbo.NashvilleHousing)

SELECT *
FROM Row_Num_CTE
WHERE row_num > 1;

-------------------------------------------------------

---Delete Unsused Columns That we do not Need

SELECT *
FROM PortfolioProject02..NashvilleHousing

ALTER TABLE PortfolioProject02..NashvilleHousing
DROP COLUMN if exists TaxDistrict