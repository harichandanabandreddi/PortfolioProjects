-- Data Cleaning

select *
from PortfolioProject.dbo.NashvilleHousing



-- 1
-- Standardize Date format

Select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

-- Update in the table

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

Select SaleDate, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

-- Its not updating. We can try using ALTER

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing




-- 2
-- Populate Property Address data

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

-- The address format seems to have everything in it. And check for NULL values as it has few

Select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is NULL

Select *
from PortfolioProject.dbo.NashvilleHousing
order by ParcelID

-- The NULL values of property address would be populated if we had a reference point
-- For same ParcelID, the address would also be same as seen in the table
-- If one ParcelID has an address, we populate the same address for same ParcelID
-- We need to self join the table to look for the equal conditions
-- Dates, Address, and ParcelID may be same for each different unique ID. So we can take those as reference and populate the address
-- If ParcelID are same and have different unique Id, then populate the address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Use ISNULL,to populate a.PropertyAddress with b.PropertyAddress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.Propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Update the address

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.Propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Check if it is updated

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.Propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]






-- 3
-- Breaking out address into Individual Columns (Address, City)
-- Delimiter is comma(,) here

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


-- Need to divide the address till comma. Use substring where it takes the string from the position 1 to comma
-- CHARINDEX - for searching any string

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


-- Need to remove comma

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address, CHARINDEX(',', PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing


-- Its taking as a number. So the below substring is going till the comma and coming back by 1

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
From PortfolioProject.dbo.NashvilleHousing


-- Now the substring takes the string after the comma

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NashvilleHousing


-- We cannot separate two values into one column without creating two other columns


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From PortfolioProject.dbo.NashvilleHousing





-- 4
-- Owner Address -(Address, City, State                                                                                                                                                        )

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


-- Instead of using substring here which might be difficult. We can use PARSENAME - used to parse object names into their respective parts. It can separate up to four parts of an object name, assuming the parts are separated by periods
-- The below query replaces the comma with a period(.) 

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
From PortfolioProject.dbo.NashvilleHousing


-- It runs backward

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


-- Add columns and values

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
From PortfolioProject.dbo.NashvilleHousing







-- 5
-- Change Y and N to Yes and No in "Sold as Vacant" field
-- Check the distinct values

Select Distinct(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing 

-- Count

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing 
group by SoldAsVacant
order by 2


-- Change them to Yes and No using a CASE statement

Select SoldAsVacant
	, CASE When SoldAsVacant = 'Y' THEN 'Yes'
			When SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END
From PortfolioProject.dbo.NashvilleHousing 


-- Update statement

Update PortfolioProject.dbo.NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
			When SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END







-- 6
-- Remove Duplicates
-- Using CTE, Window functions

Select *,
	ROW_NUMBER() OVER(Partition by ParcelID, 
									PropertyAddress, 
									SalePrice, 
									SaleDate, 
									LegalReference 
									Order by UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing 
order by ParcelID
where row_num > 1


-- Incorrect syntax of WHERE clause. We will use CTE

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(Partition by ParcelID, 
									PropertyAddress, 
									SalePrice, 
									SaleDate, 
									LegalReference 
									Order by UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing 
)
select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress


-- DELETE the duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER(Partition by ParcelID, 
									PropertyAddress, 
									SalePrice, 
									SaleDate, 
									LegalReference 
									Order by UniqueID) row_num
From PortfolioProject.dbo.NashvilleHousing 
)
DELETE
From RowNumCTE
where row_num > 1






-- 7
-- Delete Unused Columns

select *
From PortfolioProject.dbo.NashvilleHousing 


ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing 
DROP COLUMN SaleDate