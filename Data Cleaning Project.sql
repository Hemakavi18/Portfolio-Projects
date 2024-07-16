--Data Cleansing

SELECT * FROM [Portfolio Project]..Housing_data

--Standardized date format

SELECT SaleDate, CONVERT(DATE, SaleDate) FROM [Portfolio Project]..Housing_data

ALTER TABLE [Portfolio Project]..Housing_data 
ALTER COLUMN SaleDate DATE

--Property Address

SELECT PropertyAddress 
FROM [Portfolio Project]..Housing_data

SELECT * 
FROM [Portfolio Project]..Housing_data
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project]..Housing_data a JOIN [Portfolio Project]..Housing_data b 
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a SET a.PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
 FROM [Portfolio Project]..Housing_data a JOIN [Portfolio Project]..Housing_data b 
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Break out the Address into individual column

SELECT PropertyAddress, SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) AS Property_Split_Address, 
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress) ) As Property_Split_City
FROM [Portfolio Project]..Housing_data

BEGIN TRANSACTION

ALTER TABLE [Portfolio Project]..Housing_data 
ADD Property_Split_Address Nvarchar(255)

UPDATE [Portfolio Project]..Housing_data 
SET Property_Split_Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE [Portfolio Project]..Housing_data 
ADD Property_Split_City Nvarchar(255)

UPDATE [Portfolio Project]..Housing_data 
SET Property_Split_City = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

COMMIT

SELECT OwnerAddress, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) AS Owner_Splite_Address, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2) AS Owner_Splite_City, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)AS Owner_Splite_State
FROM [Portfolio Project]..Housing_data 


ALTER TABLE [Portfolio Project]..Housing_data 
ADD Owner_Splite_Address Nvarchar(255)

UPDATE [Portfolio Project]..Housing_data 
SET Owner_Splite_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE [Portfolio Project]..Housing_data 
ADD Owner_Splite_City Nvarchar(255)

UPDATE [Portfolio Project]..Housing_data 
SET Owner_Splite_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE [Portfolio Project]..Housing_data 
ADD Owner_Splite_State Nvarchar(255)

UPDATE [Portfolio Project]..Housing_data 
SET Owner_Splite_State =PARSENAME (REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and NO in soldAsvacant

SELECT DISTINCT SoldAsVacant,COUNT (SoldAsVacant)
FROM [Portfolio Project]..Housing_data
GROUP BY SoldAsVacant

SELECT CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM [Portfolio Project]..Housing_data
GROUP BY SoldAsVacant

UPDATE [Portfolio Project]..Housing_data 
SET SoldAsVacant = CASE
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

--Remove Duplication

SELECT *, ROW_NUMBER() OVER (PARTITION BY 
                               ParcelID, PropertyAddress, SaleDate, SalePrice, OwnerName, OwnerAddress
							   Order By UniqueID)
FROM [Portfolio Project]..Housing_data 

WITH Row_CTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY 
                               ParcelID, PropertyAddress, SaleDate, SalePrice, OwnerName, OwnerAddress
							   Order By UniqueID) AS Row_numb
FROM [Portfolio Project]..Housing_data
)

SELECT * FROM Row_CTE 
WHERE Row_numb > 1



WITH Row_CTE AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY 
                               ParcelID, PropertyAddress, SaleDate, SalePrice, OwnerName, OwnerAddress
							   Order By UniqueID) AS Row_numb
FROM [Portfolio Project]..Housing_data
)

DELETE FROM Row_CTE 
WHERE Row_numb > 1

--Remove Unwanted columns

ALTER TABLE [Portfolio Project]..Housing_data
DROP COLUMN LegalReference